create database IT_Asset_Management_System;
use IT_Asset_Management_System;
/* CREATE TABLE */

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Department VARCHAR(50),
    Email VARCHAR(100) UNIQUE NOT NULL);
    
CREATE TABLE Assets (
    AssetID INT PRIMARY KEY AUTO_INCREMENT,
    Type VARCHAR(50) NOT NULL,  -- Example: Laptop, Server, Router
    Model VARCHAR(100),
    PurchaseDate DATE,
    Status ENUM('Available', 'Assigned', 'In Repair', 'Disposed') DEFAULT 'Available'
);

CREATE TABLE SoftwareLicenses (
    LicenseID INT PRIMARY KEY AUTO_INCREMENT,
    SoftwareName VARCHAR(100),
    ExpiryDate DATE,
    AssignedTo INT,
    FOREIGN KEY (AssignedTo) REFERENCES Employees(EmployeeID) ON DELETE SET NULL);
    
    
CREATE TABLE AssetAssignment (
     AssignmentID INT PRIMARY KEY AUTO_INCREMENT,
     AssetID INT,
     EmployeeID INT,
     AssignmentDate DATETIME DEFAULT CURRENT_TIMESTAMP, 
     ReturnDate DATE NULL,
     FOREIGN KEY (AssetID) REFERENCES Assets(AssetID) ON DELETE CASCADE,
     FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON DELETE CASCADE);
     
/* INSERT VALUES INTO TABLES*/
INSERT INTO Employees (Name, Department, Email) VALUES
('John Doe', 'IT', 'john.doe@example.com'),
('Jane Smith', 'HR', 'jane.smith@example.com'),
('Mike Johnson', 'Finance', 'mike.johnson@example.com');

INSERT INTO Assets (Type, Model, PurchaseDate, Status) VALUES
('Laptop', 'Dell XPS 15', '2023-01-15', 'Available'),
('Server', 'HP ProLiant DL380', '2022-08-10', 'Assigned'),
('Router', 'Cisco 2900', '2021-05-20', 'Available');


INSERT INTO SoftwareLicenses (SoftwareName, ExpiryDate, AssignedTo) VALUES
('Microsoft Office', '2025-12-31', 1),
('Adobe Photoshop', '2024-10-15', 2),("Ms Excel","2024-11-12",1);


INSERT INTO AssetAssignment (AssetID, EmployeeID, AssignmentDate) VALUES
(1, 1, '2024-02-01'),
(2, 3, '2024-01-20'),(3,2,"2024-03-10");



/*VIEW ALL EMPLOYESS*/

select * from employees;


/*LIST ALL AVAILABLE ASSESTS*/
SELECT * FROM Assets WHERE Status = 'Available';



/*FIND ASSEST ASSIGHNED TO AN EMPLOYEE*/
SELECT e.Name, a.Type, a.Model, aa.AssignmentDate
FROM AssetAssignment aa
JOIN Employees e ON aa.EmployeeID = e.EmployeeID
JOIN Assets a ON aa.AssetID = a.AssetID
WHERE e.Name = 'John Doe';


/*Find Software Licenses Expiring Soon (Next 6 Months)*/

SELECT SoftwareName, ExpiryDate
FROM SoftwareLicenses
WHERE ExpiryDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 6 MONTH);


/* Count Total Assets by Type*/

SELECT Type, COUNT(*) AS TotalAssets
FROM Assets
GROUP BY Type;


/*Get Employee Who Has the Most Assets Assigned*/

SELECT e.Name, COUNT(aa.AssetID) AS TotalAssetsAssigned
FROM AssetAssignment aa
JOIN Employees e ON aa.EmployeeID = e.EmployeeID
GROUP BY e.Name
ORDER BY TotalAssetsAssigned DESC
LIMIT 1;

/*Create a Stored Procedure*/

DELIMITER //

CREATE PROCEDURE AssignAsset (IN empID INT, IN assetID INT)
BEGIN
    DECLARE assetStatus VARCHAR(20);
    
    -- Check if Asset is Available
    SELECT Status INTO assetStatus FROM Assets WHERE AssetID = assetID;
    
    IF assetStatus = 'Available' THEN
        -- Assign Asset
        INSERT INTO AssetAssignment (AssetID, EmployeeID, AssignmentDate)
        VALUES (assetID, empID, CURDATE());
        
        -- Update Asset Status
        UPDATE Assets SET Status = 'Assigned' WHERE AssetID = assetID;
        
        SELECT 'Asset Assigned Successfully' AS Message;
    ELSE
        SELECT 'Asset is Not Available' AS Message;
    END IF;
END //

DELIMITER ;



/*Call the Stored Procedure*/

SELECT * FROM AssetAssignment WHERE AssetID = 2 AND EmployeeID = 3;

/*Create a Trigger to Update Status When Returned*/
DELIMITER //

CREATE TRIGGER UpdateAssetStatusOnReturn
AFTER UPDATE ON AssetAssignment
FOR EACH ROW
BEGIN
    IF NEW.ReturnDate IS NOT NULL THEN
        UPDATE Assets SET Status = 'Available' WHERE AssetID = NEW.AssetID;
    END IF;
END //

DELIMITER ;



/*Mark an Asset as Returned*/
UPDATE AssetAssignment 
SET ReturnDate = '2025-01-31' 
WHERE AssignmentID = 1;



/*Create Indexes for Faster Queries*/
CREATE INDEX idx_asset_status ON Assets(Status);
CREATE INDEX idx_employee_name ON Employees(Name);
CREATE INDEX idx_assignment_employee ON AssetAssignment(EmployeeID);












     
     

