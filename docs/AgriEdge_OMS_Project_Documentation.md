# Full Stack Development with MERN Project Documentation Format

This documentation follows the requested format structure and adapts each section to the Salesforce-based AgriEdge OMS project.

## 1. Introduction

- Project Title: `Revolutionizing Agriculture with AgriEdge Or-Mange Ltd: A Salesforce-Driven Order Management Solution`
- Team Members:
  - `Anjana S` - Team Lead, account setup, project coordination, user scenario, tab creation support
  - `Divakar I` - Formula fields, validation rules, role creation, field-level access, process builder task
  - `Abinaya S` - Lightning app creation, field creation, user creation, Apex test class support
  - `Sanjay R` - Object creation, profile creation, Apex classes, triggers, deployment support

## 2. Project Overview

- Purpose:
  - The purpose of this project is to build a Salesforce-driven Order Management System for AgriEdge Or-Mange Ltd to improve order handling, inventory visibility, shipment tracking, and operational efficiency.
- Features:
  - Custom objects for orders, order items, inventory, and shipments
  - Formula fields for discounted totals, item totals, and stock status
  - Validation rules for shipment tracking and inventory alerts
  - Lightning app and custom tabs for user navigation
  - Flow and Apex-based automation
  - Apex triggers and test classes
  - Security configuration using roles, profiles, users, permission sets, and field-level access

## 3. Architecture

- Frontend:
  - The frontend is implemented using Salesforce Lightning Experience.
  - Users interact through a custom Lightning app named `AgriEdge`.
  - Navigation is provided through object tabs for Order, Order Item, Inventory, and Shipment.
- Backend:
  - The backend logic is implemented using Salesforce platform automation, including Flow, Apex classes, and Apex triggers.
  - Business processes such as order task creation, order total updates, payment-related actions, and shipment handling are managed on the Salesforce platform.
- Database:
  - The data layer is handled by Salesforce custom objects instead of MongoDB.
  - Main objects used:
    - `AgriEdge_Order__c`
    - `AgriEdge_OrderItem__c`
    - `AgriEdge_Inventory__c`
    - `AgriEdge_Shipment__c`
  - Standard objects used:
    - `Account`
    - `Contact`
    - `Product2`

## 4. Setup Instructions

- Prerequisites:
  - Salesforce Developer Org
  - Salesforce CLI
  - Git
- Installation:
  1. Clone the repository.
  2. Open the project folder.
  3. Authorize the Salesforce org.
  4. Deploy the metadata.
  5. Run Apex tests.

```bash
git clone https://github.com/Anju1402-official/NM-AgriEdge-OMS.git
cd NM-AgriEdge-OMS
sf org login web --alias AgriEdgeDev
sf project deploy start --target-org AgriEdgeDev
sf apex run test --target-org AgriEdgeDev --test-level RunLocalTests
```

## 5. Folder Structure

- Client:
  - This project does not use a separate React client. Salesforce Lightning UI acts as the user interface layer.
- Server:
  - This project does not use a separate Node.js server. Salesforce platform logic acts as the backend layer.
- Main project structure:

```text
NM-AgriEdge-OMS/
|-- docs/
|   |-- AgriEdge_OMS_Project_Documentation.md
|   |-- AgriEdge_OMS_Report.pdf
|   |-- AgriEdge_OMS_Demo.mp4
|   `-- AgriEdge_Process_Builder_Demo.mp4
|-- force-app/main/default/
|   |-- applications/
|   |-- classes/
|   |-- flows/
|   |-- objects/
|   |-- permissionsets/
|   |-- profiles/
|   `-- tabs/
|-- package.xml
|-- sfdx-project.json
`-- README.md
```

## 6. Running the Application

- Provide commands to start the frontend and backend servers locally:
  - This Salesforce project does not use `npm start`.
  - Instead, the application is run by deploying metadata to a Salesforce org and opening the app in Lightning Experience.
- Deployment commands:

```bash
sf org login web --alias AgriEdgeDev
sf project deploy start --target-org AgriEdgeDev
sf apex run test --target-org AgriEdgeDev --tests AgriEdgeOrderTests
```

## 7. API Documentation

- This project does not expose REST API endpoints like a MERN backend.
- Instead, the backend processing is handled by Apex classes, triggers, and Flow.
- Important logic components:
  - `AgriEdgeOrderManagementService`
  - `OrderTaskCreator`
  - `OrderStatusUpdater`
  - `OrderTotalUpdater`
  - `OrderEmailSender`
  - `AgriEdgeOrderShipmentHelper`
  - `AgriEdgeOrderTrigger`
  - `OrderPaymentStatusTriggers`
  - `OrderItemTrigger`

## 8. Authentication

- Authentication and authorization are handled by Salesforce.
- Security includes:
  - Salesforce login credentials
  - User roles
  - Custom profiles
  - Permission sets
  - Field-level security
- Profiles created:
  - `Platform 1`
  - `Platform 2`
  - `Platform 3`
- Roles created:
  - `Sales Representative`
  - `Warehouse Manager`
  - `Finance Team`

## 9. User Interface

- The user interface is built using Salesforce Lightning Experience.
- UI components included:
  - `AgriEdge` Lightning App
  - Custom tabs for all major objects
  - Object record pages for Orders, Order Items, Inventory, and Shipments
- Related visual assets:
  - Demo video in `docs/AgriEdge_OMS_Demo.mp4`
  - Process Builder video in `docs/AgriEdge_Process_Builder_Demo.mp4`

## 10. Testing

- Testing strategy:
  - Apex unit testing for automation logic
  - Validation rule checks
  - Manual verification of Flow, profiles, field access, and object behavior
- Tools used:
  - Salesforce Apex Test Execution
  - Salesforce CLI
- Test classes:
  - `AgriEdgeOrderManagementServiceTest`
  - `AgriEdgeOrderTests`

## 11. Screenshots or Demo

- GitHub Project:
  - `https://github.com/Anju1402-official/NM-AgriEdge-OMS`
- Demo Video:
  - `docs/AgriEdge_OMS_Demo.mp4`
- Process Builder Demo:
  - `docs/AgriEdge_Process_Builder_Demo.mp4`
- Report:
  - `docs/AgriEdge_OMS_Report.pdf`

## 12. Known Issues

- The `Payment Status` field could not be hidden for some profiles because Salesforce treated it as a required field.
- The original brief referenced Process Builder, while Salesforce now promotes Flow. Both automation-related assets are documented in the repository.
- Process Builder class selection in UI was inconsistent and required an invocable wrapper adjustment for `OrderTaskCreator`.

## 13. Future Enhancements

- Add dashboards and advanced Salesforce reports
- Add customer self-service portal integration
- Improve shipment tracking with external carrier integration
- Extend automation with email templates and approval flows
- Add inventory forecasting and demand analysis features
