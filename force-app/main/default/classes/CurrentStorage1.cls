global class CurrentStorage1 {
    @future(callout=true)
    public static void storageLimit(){
        HttpRequest httpn = new HttpRequest();
        httpn.setEndpoint('https://1ap--devnew.sandbox.my.salesforce.com/services/data/v53.0/limits');
        httpn.setMethod('GET');
        httpn.setHeader('Authorization','Bearer 00D72000001V5MF!AQEAQMo2S808oki6pOIow13vGlZ03PYBh1IbmIWyMrmIVpQ4o5TDpNx8zrkX5yDZe.NoiXKLNiqfSRLXGFQl5gvnnwSgnku4');
        HTTP htt = new HTTP();
        HTTPResponse htr =  htt.send(httpn);
        string responseBody = htr.getBody();
        system.debug('responseBody:: ' +htr.getBody());
        system.debug('Error:: ' +htr.getStatusCode());
        system.debug('Status:: '+htr.getStatus());
        JSON2Apex obj = JSON2Apex.parse(htr.getBody());
        system.debug('obj:: '+obj);
        system.debug(obj.AnalyticsExternalDataSizeMB.Max);
        
        Data_Storage__c ds = new Data_Storage__c();
       // ds.put('Analytics_External_Data_Size_Max__c');
        ds.Analytics_External_Data_Size_Max__c = (Integer)obj.AnalyticsExternalDataSizeMB.Max;
        ds.Analytics_External_Data_Size_Remaining__c = (Integer)obj.AnalyticsExternalDataSizeMB.Remaining;
        ds.BOZosCalloutHourlyLimit_Max__c = (Integer)obj.BOZosCalloutHourlyLimit.Max;
        ds.BOZosCalloutHourlyLimit_Remaining__c = (Integer)obj.BOZosCalloutHourlyLimit.Remaining;
        ds.ConcurrentAsyncGetReportInstances_Max__c = (Integer)obj.ConcurrentAsyncGetReportInstances.Max;
        ds.ConcurrentAsyncGetReportInstances_Remain__c = (Integer)obj.ConcurrentAsyncGetReportInstances.Remaining;
        ds.ConcurrentEinsteinDataInsightStoryCreatM__c = (Integer)obj.ConcurrentEinsteinDataInsightsStoryCreation.Max;
        ds.ConcurrentEinsteinDataInsightStoryCreatR__c = (Integer)obj.ConcurrentEinsteinDataInsightsStoryCreation.Remaining;
        ds.ConcurrentSyncReportRuns_Max__c = (Integer)obj.ConcurrentSyncReportRuns.Max;
        ds.ConcurrentSyncReportRuns_Remaining__c = (Integer)obj.ConcurrentSyncReportRuns.Remaining;
        ds.DailyAnalyticsDataflowJobExecutions_M__c = (Integer)obj.DailyAnalyticsDataflowJobExecutions.Max;
        ds.DailyAnalyticsDataflowJobExecutions_R__c = (Integer)obj.DailyAnalyticsDataflowJobExecutions.Remaining;
        ds.DailyAnalyticsUploadedFilesSize_Max__c = (Integer)obj.DailyAnalyticsUploadedFilesSizeMB.Max;
        ds.DailyAnalyticsUploadedFilesSize_Remain__c = (Integer)obj.DailyAnalyticsUploadedFilesSizeMB.Remaining;
        ds.DailyApiRequests_Max__c = (Integer)obj.DailyApiRequests.Max;
        ds.DailyApiRequests_Remain__c  = (Integer)obj.DailyApiRequests.Remaining;
        ds.DailyAsyncApexExecutions_Max__c = (Integer)obj.DailyAsyncApexExecutions.Max;
        ds.DailyAsyncApexExecutions_Remain__c = (Integer)obj.DailyAsyncApexExecutions.Remaining;
        ds.DailyBulkApiBatches_Max__c = (Integer)obj.DailyBulkApiBatches.Max;
        ds.DailyBulkApiBatches_Remain__c = (Integer)obj.DailyBulkApiBatches.Remaining;
        ds.DailyGenericStreamingApiEvents_Max__c = (Integer)obj.DailyGenericStreamingApiEvents.Max;
        ds.DailyGenericStreamingApiEvents_Remain__c = (Integer)obj.DailyGenericStreamingApiEvents.Remaining;
        ds.DailyStandardVolumePlatformEvents_Max__c = (Integer)obj.DailyStandardVolumePlatformEvents.Max;
        ds.DailyStandardVolumePlatformEvents_Remain__c = (Integer)obj.DailyStandardVolumePlatformEvents.Remaining;
        ds.DailyStreamingApiEvents_Max__c = (Integer)obj.DailyStreamingApiEvents.Max;
        ds.DailyStreamingApiEvents_Remain__c = (Integer)obj.DailyStreamingApiEvents.Remaining; 
        ds.DailyWorkflowEmails_Max__c = (Integer)obj.DailyWorkflowEmails.Max;
        ds.DailyWorkflowEmails_Remain__c = (Integer)obj.DailyWorkflowEmails.Remaining;
        ds.DataStorage_in_MB_Max__c = (Integer)obj.DataStorageMB.Max;
        ds.Data_Storage_in_MB_Remain__c = (Integer)obj.DataStorageMB.Remaining;
        ds.FileStorage_in_MB_Max__c = (Integer)obj.FileStorageMB.Max;
        ds.FileStorage_in_MB_Remain__c = (Integer)obj.FileStorageMB.Remaining;
        ds.HourlyAsyncReportRuns_Max__c = (Integer)obj.HourlyAsyncReportRuns.Max;
        ds.HourlyAsyncReportRuns_Remain__c = (Integer)obj.HourlyAsyncReportRuns.Remaining;
        ds.HourlyDashboardRefreshes_Max__c = (Integer)obj.HourlyDashboardRefreshes.Max;
        ds.HourlyDashboardRefreshes_Remain__c = (Integer)obj.HourlyDashboardRefreshes.Remaining;
        ds.HourlyLongTermIdMapping_Max__c = (Integer)obj.HourlyLongTermIdMapping.Max;
        ds.HourlyLongTermIdMapping_Remain__c = (Integer)obj.HourlyLongTermIdMapping.Remaining;
        ds.HourlyManagedContentPublicRequests_Max__c = (Integer)obj.HourlyManagedContentPublicRequests.Max;
        ds.HourlyManagedContentPublicRequests_Remn__c = (Integer)obj.HourlyManagedContentPublicRequests.Remaining;
        ds.HourlyODataCallout_Max__c = (Integer)obj.HourlyODataCallout.Max;
        ds.HourlyODataCallout_Remain__c = (Integer)obj.HourlyODataCallout.Remaining;
        ds.HourlyPublishedPlatformEvents_Max__c = (Integer)obj.HourlyPublishedPlatformEvents.Max;
        ds.HourlyPublishedPlatformEvents_Remain__c = (Integer)obj.HourlyPublishedPlatformEvents.Remaining;
        ds.HourlyPublishedStandardVolmPlatformEve_M__c = (Integer)obj.HourlyPublishedStandardVolumePlatformEvents.Max;
        ds.HourlyShortTermIdMapping_Max__c = (Integer)obj.HourlyShortTermIdMapping.Max;
        ds.HourlyShortTermIdMapping_Remain__c = (Integer)obj.HourlyShortTermIdMapping.Remaining;
        ds.HourlySyncReportRuns_Max__c = (Integer)obj.HourlySyncReportRuns.Max;
        ds.HourlySyncReportRuns_Remain__c = (Integer)obj.HourlySyncReportRuns.Remaining;
        ds.HourlyShortTermIdMapping_Max__c = (Integer)obj.HourlySyncReportRuns.Max;
        ds.HourlyShortTermIdMapping_Remain__c = (Integer)obj.HourlySyncReportRuns.Remaining;
        ds.HourlyTimeBasedWorkflow_Max__c = (Integer)obj.HourlyTimeBasedWorkflow.Max;
        ds.HourlyTimeBasedWorkflow_Remain__c = (Integer)obj.HourlyTimeBasedWorkflow.Remaining;
        ds.MassEmail_Max__c = (Integer)obj.MassEmail.Max;
        ds.MassEmail_Remain__c = (Integer)obj.MassEmail.Remaining;
        ds.Package2VersionCreates_Max__c = (Integer)obj.Package2VersionCreates.Max;
        ds.Package2VersionCreates_Remain__c = (Integer)obj.Package2VersionCreates.Remaining;
        ds.Package2VersionCreateWithoutValidtion_M__c = (Integer)obj.Package2VersionCreatesWithoutValidation.Max;
        ds.SingleEmail_Max__c = (Integer)obj.SingleEmail.Max;
        ds.SingleEmail_Remain__c = (Integer)obj.SingleEmail.Remaining;
    	Insert ds;
        
        Map<string,string>mpstr = new Map<string,string>();
        mpstr.put('AnalyticsExternalDataSizeMBMax','Analytics_External_Data_Size_Max__c');
        
        Map<string,object> dsMap = (Map<string,object>)JSON.deserializeUntyped(htr.getBody());
        system.debug('dsMap:: '+dsMap);
        for(string s : dsMap.Keyset()){
            system.debug('s:: '+s);
            system.debug('dsMap:: '+dsMap.get(s));
            //Map<String,Object>mp=(Map<String,Object>)result.get(s);
            //Map<string,Integer> mp = new Map<string,Integer>();
            //mp.putAll(dsMap.get(s));
        }
    	
        
        
        
        //obj.AnalyticsExternalDataSizeMB antd = new obj.AnalyticsExternalDataSizeMB();
        //JSON2Apex.AnalyticsExternalDataSizeMB jae = new JSON2Apex.AnalyticsExternalDataSizeMB();
       //ds.Analytics_External_Data_Size_Max__c = (string)obj.AnalyticsExternalDataSizeMB();
      // AnalyticsExternalDataSizeMB antd = (AnalyticsExternalDataSizeMB)parser.readvalueas(AnalyticsExternalDataSizeMB.class);
      JSONParser parser = JSON.createParser(htr.getBody());
        system.debug('parser:: '+parser);
        // Advance to the next token.
        while (parser.nextToken() != null) {
            system.debug('parser:: '+parser);
            // Start at the array of Abilities.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                system.debug('parser:: '+parser);
                while (parser.nextToken() != null) {
                    system.debug('parser:: '+parser);
                    // Advance to the start object marker to
                    //  find next object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        system.debug('parser:: '+parser);
                        // Read entire object.
                        JSON2Apex antd = (JSON2Apex)parser.readvalueas(JSON2Apex.class);
                        system.debug('AnalyticsExternalDataSizeMB : ' + antd.AnalyticsExternalDataSizeMB);
                        
                    }
                }
            }
        } 
    }
}