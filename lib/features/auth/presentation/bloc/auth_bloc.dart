import 'package:chatter/features/auth/domain/usecases/login_usecase.dart';
import 'package:chatter/features/auth/domain/usecases/register_usecase.dart';
import 'package:chatter/features/auth/presentation/bloc/auth_event.dart';
import 'package:chatter/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUsecase registerUseCase;
  final LoginUsecase loginUseCase;
  final _storage = FlutterSecureStorage();

  AuthBloc({required this.registerUseCase, required this.loginUseCase})
      : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await registerUseCase.call(event.username, event.email, event.password);

      emit(AuthSuccess(message: "Registration successful"));
    } catch (e) {
      emit(AuthFailure(error: "Registration failed"));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase.call(event.email, event.password);
      print(user);
      await _storage.write(key: 'Token', value: user.token);
      await _storage.write(key: 'userId', value: user.id);
      print('Token: ' + user.token);
      emit(AuthSuccess(message: "Login successful"));
    } catch (e) {
      emit(AuthFailure(error: "Login failed"));
    }
  }
}
