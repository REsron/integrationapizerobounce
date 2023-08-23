public class ZeroBounceHandler {
    //Example Endpoint https://api.zerobounce.net/v2/validate?api_key=replacewithyours&email=valid@example.com&ip_address=156.124.12.145
    //Public String Endpoint = 'https://api.zerobounce.net/v2/validate?api_key=replacewithyours&email=valid@example.com&ip_address=';
  
    public static String ZeroBounceCall(String Email){
        
        String endpointUrl = 'https://api.zerobounce.net/v2/validate?api_key='+System.Label.ApiKey+'&email='+Email+'&ip_address=';
		String Status = '';        		
        // Create an HTTP object
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        // Set the request parameters
        request.setEndpoint(endpointUrl);
        request.setMethod('GET');

        // Send the request and get the response
        HttpResponse response = http.send(request);

        // Process the response
        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            try{
               ZeroBounceResponse resp = (ZeroBounceResponse) JSON.deserialize(responseBody, ZeroBounceResponse.class);
               Status = resp.status;
            }
            catch(exception e){
                System.debug(e.getMessage());
                Status = 'Error';
            }                     
            
        } else {
            System.debug('API Request failed with status code: ' + response.getStatusCode());
            Status = 'API Request Failed';
        }
        
        return Status;
        
    }
    
}