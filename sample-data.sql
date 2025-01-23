-- SQL script to create sample data and schema for a Dolt database about Gophers

-- Create the Gopher table
CREATE TABLE Gophers (
                         GopherID CHAR(36) PRIMARY KEY DEFAULT (UUID()),
                         Name VARCHAR(100) NOT NULL,
                         Age INT NOT NULL,
                         Gender ENUM('Male', 'Female') NOT NULL,
                         Color VARCHAR(50) NOT NULL,
                         Habitat VARCHAR(100),
                         Weight DECIMAL(5, 2),
                         DateAdded DATE DEFAULT (CURRENT_DATE)
);

-- Create a table for Habitat types
CREATE TABLE Habitats (
                          HabitatID CHAR(36) PRIMARY KEY DEFAULT (UUID()),
                          HabitatName VARCHAR(100) NOT NULL,
                          Region VARCHAR(100),
                          Climate VARCHAR(50)
);

INSERT INTO Habitats (HabitatName, Region, Climate)
VALUES
    ('Meadow', 'North America', 'Temperate'),
    ('Forest', 'Europe', 'Temperate'),
    ('Mountain', 'Asia', 'Cold'),
    ('Prairie', 'South America', 'Arid'),
    ('Urban Park', 'Worldwide', 'Variable');

-- Create a table for Gopher Diet
CREATE TABLE Diets (
                       DietID CHAR(36) PRIMARY KEY DEFAULT (UUID()),
                       GopherID CHAR(36) NOT NULL,
                       FoodItem VARCHAR(100) NOT NULL,
                       QuantityGrams DECIMAL(6, 2) NOT NULL,
                       FOREIGN KEY (GopherID) REFERENCES Gophers(GopherID)
);

-- Create a table for Gopher Health Records
CREATE TABLE HealthRecords (
                               RecordID CHAR(36) PRIMARY KEY DEFAULT (UUID()),
                               GopherID CHAR(36) NOT NULL,
                               CheckupDate DATE NOT NULL,
                               HealthStatus VARCHAR(255),
                               Notes TEXT,
                               FOREIGN KEY (GopherID) REFERENCES Gophers(GopherID)
);

-- Use the dolt_commit() stored procedure to create a commit with the new tables
CALL DOLT_COMMIT('-Am', 'Initial gopher schemas');



INSERT INTO Gophers (Name, Age, Gender, Color, Habitat, Weight)
VALUES
    ('George', 4, 'Male', 'Brown', 'Meadow', 3.5),
    ('Gina', 2, 'Female', 'Gray', 'Forest', 2.8),
    ('Gary', 3, 'Male', 'Black', 'Mountain', 4.1);

INSERT INTO Diets (GopherID, FoodItem, QuantityGrams)
VALUES
    ((SELECT GopherID FROM Gophers WHERE Name = 'George'), 'Grass', 200.00),
    ((SELECT GopherID FROM Gophers WHERE Name = 'Gina'), 'Fruits', 150.50),
    ((SELECT GopherID FROM Gophers WHERE Name = 'Gary'), 'Nuts', 180.25);

INSERT INTO HealthRecords (GopherID, CheckupDate, HealthStatus, Notes)
VALUES
    ((SELECT GopherID FROM Gophers WHERE Name = 'George'), '2024-01-10', 'Healthy', 'No issues observed.'),
    ((SELECT GopherID FROM Gophers WHERE Name = 'Gina'), '2024-01-12', 'Minor Injury', 'Small scratch on paw.'),
    ((SELECT GopherID FROM Gophers WHERE Name = 'Gary'), '2024-01-15', 'Healthy', 'Good weight and active.');

-- Create a Dolt commit on the main branch
CALL dolt_commit('-am', 'Adding George, Gina, and Gary on main');


-- Checkout a new branch for the new Gophers coming in
CALL dolt_checkout('-b', 'new-gophers');

-- Insert data for the new Gophers Grace and Gordon
INSERT INTO Gophers (Name, Age, Gender, Color, Habitat, Weight)
VALUES
    ('Grace', 5, 'Female', 'Golden', 'Prairie', 3.9),
    ('Gordon', 1, 'Male', 'White', 'Urban Park', 2.3);

INSERT INTO Diets (GopherID, FoodItem, QuantityGrams)
VALUES
    ((SELECT GopherID FROM Gophers WHERE Name = 'Grace'), 'Seeds', 120.75),
    ((SELECT GopherID FROM Gophers WHERE Name = 'Gordon'), 'Vegetables', 300.00);

INSERT INTO HealthRecords (GopherID, CheckupDate, HealthStatus, Notes)
VALUES
    ((SELECT GopherID FROM Gophers WHERE Name = 'Grace'), '2024-01-18', 'Dental Issue', 'Observed mild tooth decay.'),
    ((SELECT GopherID FROM Gophers WHERE Name = 'Gordon'), '2024-01-20', 'Underweight', 'Recommended increased food intake.');

-- Create a Dolt commit on the new-gophers branch for the new Gopher data
CALL dolt_commit('-am', 'Adding Grace and Gordon on new-gophers branch');
