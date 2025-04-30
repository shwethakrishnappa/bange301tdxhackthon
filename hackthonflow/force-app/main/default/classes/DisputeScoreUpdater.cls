public with sharing class DisputeScoreUpdater {

    public class ScoreInput {
        @InvocableVariable(required=true)
        public Id recordId;

        @InvocableVariable(required=true)
        public String jsonString;
    }

    @InvocableMethod(label='Update Scores from JSON')
    public static void DisputeScoreUpdater(List<ScoreInput> inputs) {
        for (ScoreInput input : inputs) {
            try {
                Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(input.jsonString);

                Map<String, Object> party1 = (Map<String, Object>) data.get('Party1');
                Map<String, Object> party2 = (Map<String, Object>) data.get('Party2');

                Case caseRecord = new Case(Id = input.recordId);

                caseRecord.L1Score__c = (Integer) party1.get('legalScore');
                caseRecord.B1Score__c = (Integer) party1.get('businessScore');
                caseRecord.E1Score__c = (Integer) party1.get('emotionalImpactScore');

                caseRecord.L2Score__c = (Integer) party2.get('legalScore');
                caseRecord.B2Score__c = (Integer) party2.get('businessScore');
                caseRecord.E2Score__c = (Integer) party2.get('emotionalImpactScore');

                caseRecord.Scores_and_Reasons__c = input.jsonString;

                update caseRecord;

            } catch (Exception e) {
                throw new FlowException('Failed to update scores: ' + e.getMessage());
            }
        }
    }
}