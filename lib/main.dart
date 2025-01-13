import 'package:chatter/core/socket_service.dart';
import 'package:chatter/features/chat/data/datasources/messages_remote_data_source.dart';
import 'package:chatter/features/chat/data/repositories/message_repository_impl.dart';
import 'package:chatter/features/chat/domain/usecases/fetch_messages_usecase.dart';
import 'package:chatter/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chatter/features/contacts/data/datasources/contacts_remote_datasource.dart';
import 'package:chatter/features/contacts/data/repositories/contact_repository_impl.dart';
import 'package:chatter/features/contacts/domain/usecases/add_contact_usecase.dart';
import 'package:chatter/features/contacts/domain/usecases/fetch_contacts_usecase.dart';
import 'package:chatter/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:chatter/features/conversation/data/datasources/conversations_remote_data_source.dart';
import 'package:chatter/features/conversation/data/repositories/conversations_repository_impl.dart';
import 'package:chatter/features/conversation/domain/usecases/fetch_conversations_usecase.dart';
import 'package:chatter/features/conversation/presentation/bloc/conversaitons_bloc.dart';
import 'package:chatter/core/theme.dart';
import 'package:chatter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:chatter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chatter/features/auth/domain/usecases/login_usecase.dart';
import 'package:chatter/features/auth/domain/usecases/register_usecase.dart';
import 'package:chatter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatter/features/auth/presentation/pages/login_page.dart';
import 'package:chatter/features/auth/presentation/pages/register_page.dart';
import 'package:chatter/features/conversation/presentation/pages/conversations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final socketService = SocketService();
  await socketService.initSocket();
  final authRepository =
      AuthRepositoryImpl(authRemoteDataSource: AuthRemoteDatasource());
  final conversationRepository = ConversationsRepositoryImpl(
      conversationsRemoteDataSource: ConversationsRemoteDataSource());
  final messagesRepository = MessageRepositoryImpl(
      messagesRemoteDataSource: MessagesRemoteDataSource());
  final contactsRepository = ContactRepositoryImpl(
      contactsRemoteDatasource: ContactsRemoteDatasource());
  runApp(MyApp(
    authRepository: authRepository,
    conversationsRepository: conversationRepository,
    messagesRepository: messagesRepository,
    contactsRepository: contactsRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final ConversationsRepositoryImpl conversationsRepository;
  final MessageRepositoryImpl messagesRepository;
  final ContactRepositoryImpl contactsRepository;

  const MyApp(
      {super.key,
      required this.authRepository,
      required this.conversationsRepository,
      required this.messagesRepository,
      required this.contactsRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
              registerUseCase: RegisterUsecase(repository: authRepository),
              loginUseCase: LoginUsecase(repository: authRepository)),
        ),
        BlocProvider(
            create: (_) => ConversationsBloc(
                fetchConversationsUseCase:
                    FetchConversationsUseCase(conversationsRepository))),
        BlocProvider(
            create: (_) => ChatBloc(
                fetchMessagesUseCase: FetchMessagesUseCase(
                    messagesRepository: messagesRepository))),
        BlocProvider(
            create: (_) => ContactsBloc(
                fetchContactsUseCase: FetchContactsUseCase(
                    contactsRepository: contactsRepository),
                addContactUseCase:
                    AddContactUseCase(contactsRepository: contactsRepository)))
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          home: LoginPage(),
          routes: {
            '/login': (_) => LoginPage(),
            '/register': (_) => RegisterPage(),
            '/conversationsPage': (_) => ConversationsPage(),
          }),
    );
  }
}
