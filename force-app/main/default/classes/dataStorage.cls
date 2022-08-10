public class dataStorage {
    public static void storageLimit(){
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        System.OrgLimit fileStorage = limitsMap.get('FileStorageMB');
        System.debug('Limit Name: ' + fileStorage.getName());
        System.debug('Usage Value: ' + fileStorage.getValue());
        System.debug('Maximum Limit: ' + fileStorage.getLimit());
    }
}