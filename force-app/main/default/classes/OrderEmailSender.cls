public with sharing class OrderEmailSender {
    public static void sendOrderEmail(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return;
        }

        List<AgriEdge_Order__c> orders = [
            SELECT Id, Name, Total_Amount__c, Payment_Status__c, Order_Status__c,
                   Customer__c, CreatedDate, Shipping_Address__c, Discounted_Total__c
            FROM AgriEdge_Order__c
            WHERE Id IN :orderIds
        ];

        Set<Id> accountIds = new Set<Id>();
        for (AgriEdge_Order__c orderRecord : orders) {
            if (orderRecord.Customer__c != null) {
                accountIds.add(orderRecord.Customer__c);
            }
        }

        Map<Id, List<String>> accountEmails = new Map<Id, List<String>>();
        for (Contact contactRecord : [
            SELECT Email, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds
            AND Email != null
        ]) {
            if (!accountEmails.containsKey(contactRecord.AccountId)) {
                accountEmails.put(contactRecord.AccountId, new List<String>());
            }
            accountEmails.get(contactRecord.AccountId).add(contactRecord.Email);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (AgriEdge_Order__c orderRecord : orders) {
            if (!accountEmails.containsKey(orderRecord.Customer__c)) {
                continue;
            }

            String emailBody = 'Dear Customer,<br/><br/>'
                + 'Your order has been updated with the following details:<br/><br/>'
                + '<b>Order Name:</b> ' + orderRecord.Name + '<br/>'
                + '<b>Order Status:</b> ' + orderRecord.Order_Status__c + '<br/>'
                + '<b>Total Amount:</b> ' + orderRecord.Total_Amount__c + '<br/>'
                + '<b>Payment Status:</b> ' + orderRecord.Payment_Status__c + '<br/>'
                + '<b>Shipping Address:</b> ' + orderRecord.Shipping_Address__c + '<br/>'
                + '<b>Created Date:</b> ' + String.valueOf(orderRecord.CreatedDate) + '<br/><br/>'
                + '<b>Total Amount Paid (Including Discount):</b> ' + orderRecord.Discounted_Total__c + '<br/><br/>'
                + 'Thank you for your business!<br/><br/>'
                + 'Best Regards,<br/>AgriEdge OMS';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(accountEmails.get(orderRecord.Customer__c));
            email.setSubject('Your Order Payment Status has been Updated');
            email.setHtmlBody(emailBody);
            emails.add(email);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}
