import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/channels_provider.dart';
import '../providers/user_provider.dart';

import '../models/channel.dart';

class ChannelDetailScreen extends StatelessWidget {
  static const routeName = "channel-detail-screen";
  const ChannelDetailScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final modalArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final channelsProvider = Provider.of<ChannelsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final Channel channel = modalArgs["channel"];
    final bool isOwner = modalArgs["isOwner"];
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    channel.channelName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const Divider(),
                  Text(
                    channel.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.25,
            child: Container(
              width: size.width,
              height: size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Column(
                  children: [
                    // Owner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Owner",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                              size: 30,
                            )
                          ],
                        ),
                        Text(
                          channel.owner["name"],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Create Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Create Date",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.calendar_month_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 30,
                            ),
                          ],
                        ),
                        Text(
                          DateFormat.yMMMd()
                              .format(DateTime.parse(channel.createDate)),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    // Members
                    Text(
                      "Members",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                          itemCount: channel.members.length,
                          itemBuilder: (ctx, index) {
                            final member = channel.members[index];
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: isOwner
                                          ? () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30)),
                                                  content: member["is_admin"]
                                                      ? Text(
                                                          "Do you want to remove ${member["name"]} from admins?")
                                                      : Text(
                                                          "Do you want to make ${member["name"]} admin?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("No"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        if (channel
                                                                .members[index]
                                                            ["is_admin"]) {
                                                          await channelsProvider
                                                              .removeAdmin(
                                                            {
                                                              "email":
                                                                  user.email,
                                                              "password":
                                                                  user.password
                                                            },
                                                            channel.id,
                                                            member["_id"]
                                                                ["\$oid"],
                                                          );
                                                        } else {
                                                          await channelsProvider
                                                              .addAdmin(
                                                            {
                                                              "email":
                                                                  user.email,
                                                              "password":
                                                                  user.password
                                                            },
                                                            channel.id,
                                                            member["_id"]
                                                                ["\$oid"],
                                                          );
                                                        }
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("Yes"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          : null,
                                      child: Text(
                                        member["name"],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    if (member["is_admin"] == true)
                                      Text(
                                        "Admin",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    // Remove member
                                    if (isOwner)
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (ctx) {
                                                return AlertDialog(
                                                  title: const Text("Warning"),
                                                  content: Text(
                                                      "Do you want to remove ${member["name"]}?"),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text("No"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text("Yes"),
                                                      onPressed: () async {
                                                        await channelsProvider
                                                            .removeMember(
                                                          {
                                                            "email": user.email,
                                                            "password":
                                                                user.password
                                                          },
                                                          channel.id,
                                                          member["_id"]
                                                              ["\$oid"],
                                                        );
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                  ],
                                ),
                                const Divider(),
                              ],
                            );
                          }),
                    ),
                    TextButton(
                      onPressed: () async {
                        final users = await userProvider.getAllUsers(
                          {"email": user.email, "password": user.password},
                        );
                        showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50),
                                topRight: Radius.circular(50),
                              ),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            context: context,
                            builder: (ctx) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: users.isEmpty
                                    ? const Text(
                                        "Something went wrong! Couldn't find any user.")
                                    : ListView.builder(
                                        itemCount: users.length,
                                        itemBuilder: (ctx, index) {
                                          final bool isUserExists =
                                              channelsProvider
                                                  .checkMemberExists(
                                                      channel,
                                                      users[index]["_id"]
                                                          ["\$oid"]);
                                          return Column(
                                            children: [
                                              if (!isUserExists)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.person,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          users[index]["name"],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    IconButton(
                                                      onPressed: () async {
                                                        await channelsProvider
                                                            .addMember(
                                                                {
                                                              "email":
                                                                  user.email,
                                                              "password":
                                                                  user.password,
                                                            },
                                                                channel.id,
                                                                users[index]
                                                                        ["_id"]
                                                                    ["\$oid"]);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      icon: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              if (!isUserExists)
                                                const Divider(
                                                    color: Colors.white),
                                            ],
                                          );
                                        }),
                              );
                            });
                      },
                      child: Text(
                        "Add new member",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
