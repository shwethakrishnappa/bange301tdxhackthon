public class UpdateCaseEscore {

    public class InputWrapper {
        @InvocableVariable(required=true)
        public Id recordId;

        @InvocableVariable(required=true)
        public String reason; // this is a JSON string
    }

    @InvocableMethod(label='Update E1score field on Case')
    public static void updateEscore(List<InputWrapper> inputs) {
        List<Case> casesToUpdate = new List<Case>();

        for (InputWrapper input : inputs) {

            try {
                // Parse the JSON string
                //Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(input.reason);
                //Map<String, Object> party1 = (Map<String, Object>) data.get('Party1');

                System.debug(input.reason);
                String jsonString =  input.reason;
                System.debug('jsonString->'+jsonString);
                jsonString = jsonString.replaceAll('\u00A0', ' ').trim();
                List<Object> dataList = (List<Object>) JSON.deserializeUntyped(jsonString);
                System.debug(dataList);
                Integer p1Legal, p1Business, p1Emotional, p2Legal, p2Business, p2Emotional;
                
                for (Object item : dataList) {
                    Map<String, Object> record = (Map<String, Object>) item;
                    String party = (String) record.get('Party');
                    
                    if (party == 'Party1') {
                        p1Legal = (Integer) record.get('LegalScore');
                        p1Business = (Integer) record.get('BusinessScore');
                        p1Emotional = (Integer) record.get('EmotionalImpactScore');
                    } else if (party == 'Party2') {
                        p2Legal = (Integer) record.get('LegalScore');
                        p2Business = (Integer) record.get('BusinessScore');
                        p2Emotional = (Integer) record.get('EmotionalImpactScore');
                    }
                }
               // System.debug(p1Legalp1Business, p1Emotional, p2Legal, p2Business, p2Emotional)
                //System.assertEquals('abc','jkl');

                // Extract score from party1
                Decimal emotionalScore = 20;

                if (input.recordId != null) {
                    casesToUpdate.add(new Case(
                        Id = input.recordId,
                        L1score__c = p1Legal,
                        B1score__c = p1Business,
                        E1score__c = p1Emotional,
                        L2score__c = p2Legal,
                        B2score__c = p2Business,
                        E2score__c = p2Emotional,
                        
                        Scores_and_Reasons__c = input.reason
                    ));
                }

            } catch (Exception e) {
                throw new System.FlowException('Failed to update scores: ' + e.getMessage());
            }
        }

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
}