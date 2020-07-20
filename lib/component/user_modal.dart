import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stingray/component/story_list.dart';
import 'package:stingray/model/user.dart';
import 'package:stingray/repo.dart';

final usersProvider = FutureProvider.family((ref, String id) async {
  return await Repo.fetchUser(id);
});

class UserModal extends HookWidget {
  UserModal({this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    AsyncValue<User> user = useProvider(usersProvider(username));

    return user.when(
      loading: () =>
          SafeArea(child: Center(child: CircularProgressIndicator())),
      error: (err, stacktrace) => SafeArea(child: Center(child: Text("$err"))),
      data: (user) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 1,
            maxChildSize: 1,
            builder: (context, controller) {
              return CustomScrollView(
                controller: controller,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: Text(
                              user.id,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "${user.karma}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                                TextSpan(
                                  text: " ${String.fromCharCode(8226)} ",
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                TextSpan(
                                  text: user.since,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (user.about != null) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "About",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Html(
                          data: user.about,
                        ),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Submissions",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: StoryList(ids: user.submitted),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
