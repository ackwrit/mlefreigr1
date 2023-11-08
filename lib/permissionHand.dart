import 'package:permission_handler/permission_handler.dart';

class MyPermissionPhoto{



  init() async {
    PermissionStatus permissionStatus = await Permission.photos.status;
    checkPermission(permissionStatus);
  }

  Future<PermissionStatus>checkPermission(PermissionStatus status) async{
    switch(status){
      case PermissionStatus.permanentlyDenied:return Future.error("L'utilisateur ne souhaite pas qu'on accède à ses photos");
      case PermissionStatus.denied: return Permission.photos.request();
      case PermissionStatus.limited: return Permission.photos.request();
      case PermissionStatus.provisional: return Permission.photos.request();
      case PermissionStatus.restricted: return Permission.photos.request();
      case PermissionStatus.granted: return Permission.photos.request();
    }
  }
}