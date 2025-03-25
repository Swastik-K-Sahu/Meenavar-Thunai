import 'package:get_it/get_it.dart';
import '../core/services/auth_service.dart';
import '../core/services/local_storage_service.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Services
  locator.registerLazySingleton<AuthService>(() => AuthService());

  // // Initialize local storage service
  final localStorageService = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(localStorageService);

  // ViewModels
  locator.registerFactory<AuthViewModel>(
    () => AuthViewModel(
      authService: locator<AuthService>(),
      storageService: locator<LocalStorageService>(),
    ),
  );
}
