package main

import (
	"fmt"
	"log"

	// Import the MySQL driver for database/sql
	// Note that since we don't use the driver directly, we need to use the blank identifier
	// to avoid compilation errors
	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
)

func main() {
	// STEP 1: Connect to the database
	dsn := "root@tcp(127.0.0.1:3306)/doltdb"
	db := sqlx.MustOpen("mysql", dsn)
	defer db.Close()

	// Test the connection
	if err := db.Ping(); err != nil {
		log.Fatal(err)
	}

	fmt.Println("Connected to Dolt database!")

	// STEP 2: Run a simple SELECT query and display the results
	rows, err := db.Queryx("SELECT name, habitat FROM Gophers")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	for rows.Next() {
		var name, habitat string
		if err := rows.Scan(&name, &habitat); err != nil {
			log.Fatal(err)
		}
		fmt.Printf("Name: %s, Habitat: %s\n", name, habitat)
	}

	// STEP 3: Change a value in the database and create a Dolt commit
	stmt, err := db.Preparex("UPDATE Gophers SET weight = ? WHERE name = ?")
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	stmt.MustExec(4.20, "Gary")
	stmt.MustExec(2.85, "Gina")
	stmt.MustExec(3.45, "George")
	db.MustExec("CALL dolt_commit('--skip-empty', '-am', 'Update gopher weights');")
	fmt.Println("Updated gopher weights")

	// STEP 4: Diff the changes between new-gophers and main
	// use dolt_diff_summary() to get a summary of what tables have changes
	rows, err = db.Queryx("SELECT * from dolt_diff_summary('main', 'new-gophers');")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	fmt.Printf("Tables changed: \n")
	for rows.Next() {
		diffSummaryRow := make(map[string]interface{})
		err = rows.MapScan(diffSummaryRow)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf(" - Table: %s, Data Change: %b, Schema Change: %b, Diff Type: %s\n",
			diffSummaryRow["to_table_name"], diffSummaryRow["data_change"],
			diffSummaryRow["schema_change"], diffSummaryRow["diff_type"])
	}

	// use dolt_diff() to get the specific changes in the Gophers table
	rows, err = db.Queryx("SELECT * from dolt_diff('main', 'new-gophers', 'gophers');")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	fmt.Printf("Gopher table changes: \n")
	for rows.Next() {
		diffRow := make(map[string]interface{})
		err = rows.MapScan(diffRow)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf(" - Gopher ID: %s \n", diffRow["to_GopherID"])

		switch string(diffRow["diff_type"].([]uint8)) {
		case "added":
			fmt.Printf("   Added (%s, %v, %s, %s, %s, %s) \n",
				diffRow["to_Name"], diffRow["to_Age"], diffRow["to_Gender"], diffRow["to_Color"], diffRow["to_Habitat"], diffRow["to_Weight"])
		case "deleted":
			fmt.Printf("   Deleted (%s, %v, %s, %s, %s, %s) \n",
				diffRow["from_Name"], diffRow["from_Age"], diffRow["from_Gender"], diffRow["from_Color"], diffRow["from_Habitat"], diffRow["from_Weight"])
		case "modified":
			fmt.Printf("   Changed from (%s, %v, %s, %s, %s, %s) to (%s, %v, %s, %s, %s, %s)\n",
				diffRow["from_Name"], diffRow["from_Age"], diffRow["from_Gender"], diffRow["from_Color"], diffRow["from_Habitat"], diffRow["from_Weight"],
				diffRow["to_Name"], diffRow["to_Age"], diffRow["to_Gender"], diffRow["to_Color"], diffRow["to_Habitat"], diffRow["to_Weight"])
		}
	}
}
