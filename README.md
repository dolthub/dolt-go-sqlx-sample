# dolt-go-sqlx-sample
Sample project using the [jmoiron/sqlx](https://github.com/jmoiron/sqlx) library to connect to a [Dolt database](https://doltdb.com/).

Check out [the associated blog post for an in-depth walkthrough](https://www.dolthub.com/blog/2025-01-24-go-sql-with-dolt/) on how to connect to a Dolt database in a Go application using this sample code.

# Running the Sample
Before you can run this sample code, you need to start up a Dolt SQL server for this code to connect to. If you don't already have Dolt installed, head over to the [Dolt installation docs](https://docs.dolthub.com/introduction/installation) and follow the instructions to install Dolt.

## Start a Dolt SQL Server
Once Dolt is installed, create a directory for your new Dolt database and initialize it as a Dolt database directory. The directory name you use here will be the name of the Dolt database, so make sure you use `doltdb` since that's the database name the sample code is expecting:
```bash
mkdir doltdb && cd doltdb
dolt init
```

After you run `dolt init`, you'll have a working Dolt database directory. Next, use the `sample-data.sql` file in this project to create some sample data in your database:
```bash
wget https://raw.githubusercontent.com/dolthub/dolt-go-sqlx-sample/refs/heads/main/sample-data.sql
dolt sql < sample-data.sql
```

After creating the sample data, you can start up the Dolt SQL server:
```bash
dolt sql-server
```

## Run the Sample Code
Once you've got some sample data loaded into your Dolt database, you're ready to run the sample code! You can execute the code directly from your IDE's tooling, or you can run it from the command line using go:
```shell
 go run ./main.go
```

# Help!
If you run into any problems using this sample code, or just want some help integrating your application with Dolt, come join the [DoltHub Discord server](https://discord.gg/gqr7K4VNKe) and connect with our development team as well as other Dolt customers. We'll be happy to learn more about what you're building and help you get Dolt working! 
