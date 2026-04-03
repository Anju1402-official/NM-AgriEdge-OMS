# AgriEdge OMS Salesforce Project

AgriEdge Or-Mange Ltd is modernizing its agriculture order management process with a Salesforce-based Order Management System (OMS). This repository now contains a deployable Salesforce DX implementation that covers the core order, inventory, shipment, automation, and security requirements from the project brief.

## Project Goals

- Automate order processing and reduce manual errors
- Track inventory levels in real time
- Support responsive customer service with current order data
- Enforce data quality with formula fields and validation rules
- Provide a secure, extensible Salesforce foundation

## What Is Included

- Custom objects for orders, order items, inventory, and shipments
- Formula fields for discounted totals, line totals, and stock status
- Validation rules for low inventory and shipment tracking enforcement
- A Lightning app and custom tabs
- A record-triggered flow for new-order follow-up task creation
- Apex trigger logic to recalculate order totals and update inventory
- Apex tests for core OMS behaviors
- A permission set for AgriEdge OMS users
- Project report PDF in `docs/AgriEdge_OMS_Report.pdf`

## Salesforce Components

- `AgriEdge_Order__c`
- `AgriEdge_OrderItem__c`
- `AgriEdge_Inventory__c`
- `AgriEdge_Shipment__c`
- `AgriEdge_New_Order_Followup` flow
- `AgriEdgeOrderItemTrigger`
- `AgriEdgeOrderManagementService`

## Project Structure

```text
Salesforce-Developer---NM-Engg-AgriEdge-OMS-/
|-- docs/
|   `-- AgriEdge_OMS_Report.pdf
|-- force-app/main/default/
|   |-- applications/
|   |-- classes/
|   |-- flows/
|   |-- objects/
|   |-- permissionsets/
|   `-- tabs/
|-- package.xml
|-- sfdx-project.json
`-- README.md
```

## Deployment

1. Install Salesforce CLI.
2. Authorize your Salesforce org.
3. Deploy the metadata.
4. Run Apex tests.

```bash
sf org login web --alias AgriEdgeDev
sf project deploy start --target-org AgriEdgeDev
sf apex run test --target-org AgriEdgeDev --test-level RunLocalTests
```

## Notes

- The original brief mentions Process Builder. Salesforce now recommends Flow, so the automation here is implemented as a record-triggered Flow.
- The shipment lookup is modeled against `AgriEdge_Order__c` so the custom OMS objects stay consistent.
- The repository has been cleaned to keep only project-relevant Salesforce metadata and documentation.

## Team Context

This repository preserves the original project context from the GitHub starter history while adding the full Salesforce DX implementation for the AgriEdge OMS solution.
