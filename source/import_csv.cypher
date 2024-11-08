// tag::indexes[]
CREATE INDEX ON :Product(productID);
CREATE INDEX ON :Product(productName);
CREATE INDEX ON :Category(categoryID);
CREATE INDEX ON :Employee(employeeID);
CREATE INDEX ON :Supplier(supplierID);
CREATE INDEX ON :Customer(customerID);
CREATE INDEX ON :Customer(customerName);
// end::indexes[]

// tag::nodes[]
// Create customers
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "https://gist.githubusercontent.com/alvin-yang68/f2158a20755627f23f4c5f571f77d294/raw/customers.csv" AS row
CREATE (:Customer {companyName: row.CompanyName, customerID: row.CustomerID, fax: row.Fax, phone: row.Phone});

// Create products
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "https://gist.githubusercontent.com/alvin-yang68/f2158a20755627f23f4c5f571f77d294/raw/products.csv" AS row
CREATE (:Product {productName: row.ProductName, productID: row.ProductID, unitPrice: toFloat(row.UnitPrice)});

// Create suppliers
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "https://gist.githubusercontent.com/alvin-yang68/f2158a20755627f23f4c5f571f77d294/raw/suppliers.csv" AS row
CREATE (:Supplier {companyName: row.CompanyName, supplierID: row.SupplierID});

// Create employees
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "https://gist.githubusercontent.com/alvin-yang68/f2158a20755627f23f4c5f571f77d294/raw/employees.csv" AS row
CREATE (:Employee {employeeID:row.EmployeeID,  firstName: row.FirstName, lastName: row.LastName, title: row.Title});

// Create categories
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "https://gist.githubusercontent.com/alvin-yang68/f2158a20755627f23f4c5f571f77d294/raw/categories.csv" AS row
CREATE (:Category {categoryID: row.CategoryID, categoryName: row.CategoryName, description: row.Description});

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "https://gist.githubusercontent.com/alvin-yang68/f2158a20755627f23f4c5f571f77d294/raw/orders.csv" AS row
MERGE (order:Order {orderID: row.OrderID}) ON CREATE SET order.shipName =  row.ShipName;
// end::nodes[]

// tag::constraints[]
CREATE CONSTRAINT ON (o:Order) ASSERT o.orderID IS UNIQUE;
// end::constraints[]


// tag::rels_orders[]
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "https://gist.githubusercontent.com/alvin-yang68/f2158a20755627f23f4c5f571f77d294/raw/orders.csv" AS row
MATCH (order:Order {orderID: row.OrderID})
MATCH (product:Product {productID: row.ProductID})
MERGE (order)-[pu:PRODUCT]->(product)
ON CREATE SET pu.unitPrice = toFloat(row.UnitPrice), pu.quantity = toFloat(row.Quantity);

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "https://gist.githubusercontent.com/alvin-yang68/f2158a20755627f23f4c5f571f77d294/raw/orders.csv" AS row
MATCH (order:Order {orderID: row.OrderID})
MATCH (employee:Employee {employeeID: row.EmployeeID})
MERGE (employee)-[:SOLD]->(order);

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "https://gist.githubusercontent.com/alvin-yang68/f2158a20755627f23f4c5f571f77d294/raw/orders.csv" AS row
MATCH (order:Order {orderID: row.OrderID})
MATCH (customer:Customer {customerID: row.CustomerID})
MERGE (customer)-[:PURCHASED]->(order);
// end::rels_orders[]

// tag::rels_products[]
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "https://gist.githubusercontent.com/alvin-yang68/f2158a20755627f23f4c5f571f77d294/raw/products.csv" AS row
MATCH (product:Product {productID: row.ProductID})
MATCH (supplier:Supplier {supplierID: row.SupplierID})
MERGE (supplier)-[:SUPPLIES]->(product);

:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "https://gist.githubusercontent.com/alvin-yang68/f2158a20755627f23f4c5f571f77d294/raw/products.csv" AS row
MATCH (product:Product {productID: row.ProductID})
MATCH (category:Category {categoryID: row.CategoryID})
MERGE (product)-[:PART_OF]->(category);
// end::rels_products[]

// tag::rels_employees[]
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "https://gist.githubusercontent.com/alvin-yang68/f2158a20755627f23f4c5f571f77d294/raw/employees.csv" AS row
MATCH (employee:Employee {employeeID: row.EmployeeID})
MATCH (manager:Employee {employeeID: row.ReportsTo})
MERGE (employee)-[:REPORTS_TO]->(manager);
// end::rels_employees[]