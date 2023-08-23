public without sharing class EmailValidator {

    @AuraEnabled(cacheable=true)
    public static String ProcessLead(String RecId){
        String DebugLog = '';
        Boolean RecordUpdation = False;
        Boolean Error = False;
        String Output = '';
        
        //Comment 1 : Checking the Received Parameter is not Blank or Not Null
        
        if( RecId!=null && RecId != '' && !String.isBlank(RecId)){
            Lead CurrentLead = [SELECT Id, Name, Company, Email, LeadSource, Status, CreatedById, LastModifiedById, Parcel_Number__c, Assessed_Value__c, Lead_Generator__c, Starting_Bid__c, Estimated_Retail_Value_70_Calc__c, State__c, Expected_Auction_Sales_Price__c, Case_Number_Certificate_Number__c, Matrix__c, Email_1__c, Email_2__c, Email_3__c, Email_10__c, Email_4__c, Email_5__c, Email_6__c, Email_7__c, Email_8__c, Email_9__c, Email_Validation_Response_1__c, Email_Validation_Response_2__c, Email_Validation_Response_4__c, Email_Validation_Response_3__c, Email_Validation_Response_5__c, Email_Validation_Response_8__c, Email_Validation_Response_7__c, Email_Validation_Response_9__c, Email_Validation_Response_10__c, Email_Validation_Response_6__c FROM Lead WHERE Id =: RecId];
            
            //Comment 2 : Querying the Record with Received Parameter and Checking the data is not null
            
            if(CurrentLead != null){
                
                //Comment 3 : Looping the Series of Emails and EmailValidation Fields
                //If in Future needed to Upgrade the List of Fields, Create the Email and Email Validation Fields with Same Synatx of Api Names
                //It can be useful for Scalability of this Method
                
                for (Integer i = 1; i <= 10; i++) {
                    String EmailField = 'Email_' + i + '__c';
                    String EmailRes = 'Email_Validation_Response_'+i+'__c';
                    if (CurrentLead.get(EmailField) != null && (CurrentLead.get(EmailRes) == 'NotVerified' || CurrentLead.get(EmailRes) == null ) ) {
                        // Comment 4 : Check if the Email 1[i] is Not Null and Email_Validation_Response_1__c[i] is NotVerified or Null 
                        String emailValue = (String)CurrentLead.get(EmailField);
                        String Email_Validation_Response = (String)CurrentLead.get(EmailRes);
                        DebugLog += 'Email ' + i + ': ' + emailValue+ ' -- Verification Status is -->'+Email_Validation_Response;
                        try{
                            
                            // Comment 5: Calling the Api and Storing the response in String
                           
                            String apiresponse = ZeroBounceHandler.ZeroBounceCall(emailValue);
                            if(apiresponse != 'Error' || apiresponse != 'API Request Failed' ){
                                
                                // Comment 6 :  If the Api Response is not Error or Not API Request Failed, Process Further
                                DebugLog += 'Email '+ i +' Api Response --> ' +apiresponse +'/n';
                                System.debug('apiresponse -->'+ i +' '+ apiresponse);  
                                recordUpdation = recordUpdation ? recordUpdation : true;                                
                                CurrentLead.put(EmailRes, apiresponse);                            
                            }
                            
                        }catch(exception e){
                            //Comment 7 : If There is Exceptions We are logging it
                            DebugLog += emailValue +' Error Message is :'+ e.getMessage();
                            Error = Error ? Error : true;
                        }
                        
                        DebugLog += 'Email'+ i + ' is Processed /n';
                        System.debug('Response --> '+DebugLog);
                    }else{
                        DebugLog += 'Email' + i + 'Is Not Validated /n';
                        System.debug('Response --> '+DebugLog);
                    }
                
            }
            }
            
            if(RecordUpdation && CurrentLead!=null ){
                Output = Error ? 'Error' : 'Success';
                update CurrentLead;
            }
        }else{
            DebugLog +='Passed Id is Null';
            Output = Error ? 'Error' : 'Idisnull';
            System.debug('Response --> '+DebugLog);
        }
        System.debug('Response --> '+DebugLog);
        System.debug('Final Output --> '+Output);
        return Output;
    }

}