import 'package:chatter/core/theme.dart';
import 'package:chatter/features/chat/presentation/pages/chat_page.dart';
import 'package:chatter/features/contacts/presentation/pages/contacts_page.dart';
import 'package:chatter/features/conversation/presentation/bloc/conversaitons_bloc.dart';
import 'package:chatter/features/conversation/presentation/bloc/conversations_event.dart';
import 'package:chatter/features/conversation/presentation/bloc/conversations_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    BlocProvider.of<ConversationsBloc>(context).add(FetchConversations());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
            ),
            child: Text(
              'Recent',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Container(
            height: 100,
            padding: EdgeInsets.all(5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecentContact('Barry', context),
                _buildRecentContact('Barry', context),
                _buildRecentContact('Barry', context),
                _buildRecentContact('Barry', context),
                _buildRecentContact('Barry', context),
                _buildRecentContact('Barry', context),
                _buildRecentContact('Barry', context),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DefaultColors.messageListPage,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: BlocBuilder<ConversationsBloc, ConversationsState>(
                builder: (context, state) {
                  if (state is ConversationsLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is ConversationsLoaded) {
                    return state.conversations.length == 0
                        ? Center(
                            child: Text(
                                'Why you are so lonely make some friends 😊'))
                        : ListView.builder(
                            itemCount: state.conversations.length,
                            itemBuilder: (context, index) {
                              final conversation = state.conversations[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                              conversationId: conversation.id,
                                              mate: conversation
                                                  .participantName)));
                                },
                                child: _buildMessageTile(
                                    conversation.participantName,
                                    conversation.lastMessage,
                                    conversation.lastMessageTime.toString()),
                              );
                            },
                          );
                  } else if (state is ConversationsError) {
                    return Center(child: Text(state.message));
                  }
                  return Center(child: Text('No conversation'));
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ContactsPage()));
          },
          backgroundColor: DefaultColors.buttonColor,
          child: Icon(Icons.contacts)),
    );
  }

  Widget _buildMessageTile(String name, String message, String time) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(
            'https://media.istockphoto.com/id/1298261537/vector/blank-man-profile-head-icon-placeholder.jpg?s=1024x1024&w=is&k=20&c=4ZDljeyUFFmyjlHUV0BYEMWTr8SyKQR6FMWtew14jq0='),
      ),
      title: Text(
        name,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        message,
        style: TextStyle(color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        time,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildRecentContact(String name, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
                'https://media.istockphoto.com/id/1298261537/vector/blank-man-profile-head-icon-placeholder.jpg?s=1024x1024&w=is&k=20&c=4ZDljeyUFFmyjlHUV0BYEMWTr8SyKQR6FMWtew14jq0='),
          ),
          SizedBox(height: 5),
          Text(
            'test',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
