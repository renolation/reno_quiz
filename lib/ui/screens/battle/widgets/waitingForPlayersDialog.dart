import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/customDialog.dart';
import 'package:flutterquiz/ui/widgets/exitGameDialog.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:share_plus/share_plus.dart';

class WaitingForPlayerDialog extends StatefulWidget {
  final QuizTypes quizType;
  final String? battleLbl;

  const WaitingForPlayerDialog(
      {super.key, required this.quizType, this.battleLbl});

  @override
  State<WaitingForPlayerDialog> createState() => _WaitingForPlayerDialogState();
}

class _WaitingForPlayerDialogState extends State<WaitingForPlayerDialog> {
  Widget profileAndNameContainer(
      BuildContext context,
      BoxConstraints constraints,
      String name,
      String profileUrl,
      Color borderColor) {
    return Column(
      children: [
        Container(
          width: constraints.maxWidth * (0.285),
          decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).colorScheme.secondary)),
          height: constraints.maxHeight * (0.15),
          padding: const EdgeInsets.symmetric(
            horizontal: 2.5,
            vertical: 2.5,
          ),
          child: profileUrl.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(UiUtils.getImagePath("friend.svg")),
                )
              : CachedNetworkImage(
                  imageUrl: profileUrl,
                ),
        ),
        SizedBox(
          height: constraints.maxHeight * (0.015),
        ),
        Container(
          width: constraints.maxWidth * (0.3),
          height: constraints.maxHeight * (0.05),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            name.isEmpty
                ? AppLocalization.of(context)!
                    .getTranslatedValues('waitingLbl')!
                : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.background,
            ),
          ),
        ),
      ],
    );
  }

  void showRoomDestroyed(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: AlertDialog(
              content: Text(
                AppLocalization.of(context)!
                    .getTranslatedValues('roomDeletedOwnerLbl')!,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues('okayLbl')!,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ))
              ],
            )));
  }

  void onBackEvent() {
    if (widget.quizType == QuizTypes.battle) {
      print("BattleCreated${context.read<BattleRoomCubit>().state.toString()}");
      print("UserNotFound${context.read<BattleRoomCubit>().state.toString()}");
      if (context.read<BattleRoomCubit>().state is BattleRoomCreated ||
          context.read<BattleRoomCubit>().state is BattleRoomUserFound) {
        //if user
        showDialog(
            context: context,
            builder: (context) => ExitGameDialog(
                  onTapYes: () {
                    bool createdRoom = false;

                    if (context.read<BattleRoomCubit>().state
                        is BattleRoomUserFound) {
                      createdRoom = (context.read<BattleRoomCubit>().state
                                  as BattleRoomUserFound)
                              .battleRoom
                              .user1!
                              .uid ==
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId;
                    } else {
                      createdRoom = (context.read<BattleRoomCubit>().state
                                  as BattleRoomCreated)
                              .battleRoom
                              .user1!
                              .uid ==
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId;
                    }
                    //if room is created by current user then delete room
                    if (createdRoom) {
                      context.read<BattleRoomCubit>().deleteBattleRoom(
                          false); // : context.read<MultiUserBattleRoomCubit>().deleteMultiUserBattleRoom();
                    } else {
                      context
                          .read<BattleRoomCubit>()
                          .removeOpponentFromBattleRoom();
                    }
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ));
      } else if (context.read<BattleRoomCubit>().state is BattleRoomFailure) {
        Navigator.of(context).pop();
      }
    } else {
      print("TapOccurs");
      //
      showDialog(
          context: context,
          builder: (context) => ExitGameDialog(
                onTapYes: () {
                  bool createdRoom = (context
                              .read<MultiUserBattleRoomCubit>()
                              .state as MultiUserBattleRoomSuccess)
                          .battleRoom
                          .user1!
                          .uid ==
                      context.read<UserDetailsCubit>().getUserProfile().userId;

                  //if room is created by current user then delete room
                  if (createdRoom) {
                    context
                        .read<MultiUserBattleRoomCubit>()
                        .deleteMultiUserBattleRoom();
                  } else {
                    //if room is not created by current user then remove user from room
                    context.read<MultiUserBattleRoomCubit>().deleteUserFromRoom(
                        context
                            .read<UserDetailsCubit>()
                            .getUserProfile()
                            .userId!);
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      onWillPop: () {
        print("TopBakcpress");
        onBackEvent();
        return Future.value(false);
      },
      onBackButtonPress: () {
        //  print("Bakcpress");
        onBackEvent();
      },
      height: MediaQuery.of(context).size.height * (0.8),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UiUtils.dialogRadius),
            color: Theme.of(context).scaffoldBackgroundColor),
        child: widget.quizType == QuizTypes.battle
            ? BlocListener<BattleRoomCubit, BattleRoomState>(
                bloc: context.read<BattleRoomCubit>(),
                listener: (context, state) {
                  if (state is BattleRoomUserFound) {
                    //if game is ready to play
                    if (state.battleRoom.readyToPlay!) {
                      //if user has joined room then navigate to quiz screen
                      if (state.battleRoom.user1!.uid !=
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId) {
                        Navigator.of(context).pushReplacementNamed(
                            Routes.battleRoomQuiz,
                            arguments: {
                              "battleLbl": widget.battleLbl,
                              "isTournamentBattle": false
                            });
                      }
                    }

                    //if owner deleted the room then show this dialog
                    if (!state.isRoomExist) {
                      if (context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId !=
                          state.battleRoom.user1!.uid) {
                        //Room destroyed by owner
                        showRoomDestroyed(context);
                      }
                    }
                  }
                },
                child: LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    children: [
                      Container(
                        height: constraints.maxHeight * (0.11),
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(UiUtils.dialogRadius),
                            topRight: Radius.circular(UiUtils.dialogRadius),
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "${AppLocalization.of(context)!.getTranslatedValues('entryAmountLbl')!} : ${context.read<BattleRoomCubit>().getEntryFee()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    onPressed: () {
                                      try {
                                        String inviteMessage =
                                            "$groupBattleInviteMessage${context.read<BattleRoomCubit>().getRoomCode()}";
                                        Share.share(inviteMessage);
                                      } catch (e) {
                                        UiUtils.setSnackbar(
                                            AppLocalization.of(context)!
                                                .getTranslatedValues(
                                                    convertErrorCodeToLanguageKey(
                                                        defaultErrorMessageCode))!,
                                            context,
                                            false);
                                      }
                                    },
                                    iconSize: 20,
                                    icon: const Icon(Icons.share),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                  ))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.025),
                      ),
                      Container(
                        width: constraints.maxWidth * (0.85),
                        height: constraints.maxHeight * (0.175),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    //
                                    child: Text(
                                        "${AppLocalization.of(context)!.getTranslatedValues('roomCodeLbl')!} : ${context.read<BattleRoomCubit>().getRoomCode()}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          height: 1.2,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                                AppLocalization.of(context)!
                                    .getTranslatedValues('shareRoomCodeLbl')!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13.5,
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.0275),
                      ),
                      BlocBuilder<BattleRoomCubit, BattleRoomState>(
                        bloc: context.read<BattleRoomCubit>(),
                        builder: (context, state) {
                          if (state is BattleRoomUserFound) {
                            return profileAndNameContainer(
                                context,
                                constraints,
                                state.battleRoom.user1!.name,
                                state.battleRoom.user1!.profileUrl,
                                Theme.of(context).colorScheme.background);
                          }
                          if (state is BattleRoomCreated) {
                            return profileAndNameContainer(
                                context,
                                constraints,
                                state.battleRoom.user1!.name,
                                state.battleRoom.user1!.profileUrl,
                                Theme.of(context).colorScheme.background);
                          }
                          return profileAndNameContainer(context, constraints,
                              "", "", Theme.of(context).colorScheme.background);
                        },
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.027),
                      ),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          AppLocalization.of(context)!
                              .getTranslatedValues('vsLbl')!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.background),
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.03),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
                          bloc: context.read<BattleRoomCubit>(),
                          builder: (context, state) {
                            if (state is BattleRoomUserFound) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  profileAndNameContainer(
                                      context,
                                      constraints,
                                      state.battleRoom.user2!.name,
                                      state.battleRoom.user2!.profileUrl,
                                      Colors.black54),
                                ],
                              );
                            }
                            if (state is BattleRoomCreated) {
                              return profileAndNameContainer(
                                  context,
                                  constraints,
                                  "",
                                  "",
                                  Theme.of(context).colorScheme.background);
                            }
                            return Container();
                          },
                        ),
                      ),
                      const Spacer(),
                      BlocBuilder<BattleRoomCubit, BattleRoomState>(
                        bloc: context.read<BattleRoomCubit>(),
                        builder: (context, state) {
                          if (state is BattleRoomCreated) {
                            return TextButton(
                              onPressed: () async {
                                //need minimum 2 player to start the game
                                //mark as ready to play in database
                                if (state.battleRoom.user2!.uid.isEmpty) {
                                  UiUtils.errorMessageDialog(
                                      context,
                                      AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              convertErrorCodeToLanguageKey(
                                                  canNotStartGameCode)));
                                } else {
                                  context.read<BattleRoomCubit>().startGame();
                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                                  //navigate to quiz screen
                                  Navigator.of(context).pushReplacementNamed(
                                      Routes.battleRoomQuiz,
                                      arguments: {
                                        "battleLbl": widget.battleLbl,
                                        "isTournamentBattle": false
                                      });
                                }
                              },
                              child: Text(
                                  AppLocalization.of(context)!
                                      .getTranslatedValues('startLbl')!,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: Theme.of(context).primaryColor)),
                            );
                          }
                          if (state is BattleRoomUserFound) {
                            if (state.battleRoom.user1!.uid !=
                                context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile()
                                    .userId) {
                              return Container();
                            }

                            return TextButton(
                              onPressed: () async {
                                //need minimum 2 player to start the game
                                //mark as ready to play in database
                                if (state.battleRoom.user2!.uid.isEmpty) {
                                  UiUtils.errorMessageDialog(
                                      context,
                                      AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              convertErrorCodeToLanguageKey(
                                                  canNotStartGameCode)));
                                } else {
                                  context.read<BattleRoomCubit>().startGame();
                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                                  //navigate to quiz screen
                                  Navigator.of(context).pushReplacementNamed(
                                      Routes.battleRoomQuiz,
                                      arguments: {
                                        "battleLbl": widget.battleLbl,
                                        "isTournamentBattle": false
                                      });
                                }
                              },
                              child: Text(
                                  AppLocalization.of(context)!
                                      .getTranslatedValues('startLbl')!,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: Theme.of(context).primaryColor)),
                            );
                          }
                          return Container();
                        },
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.01),
                      ),
                    ],
                  );
                }),
              )
            : BlocListener<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
                listener: (context, state) {
                  if (state is MultiUserBattleRoomSuccess) {
                    //if game is ready to play
                    if (state.battleRoom.readyToPlay!) {
                      //if user has joined room then navigate to quiz screen
                      if (state.battleRoom.user1!.uid !=
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId) {
                        Navigator.of(context).pushReplacementNamed(
                            Routes.multiUserBattleRoomQuiz);
                      }
                    }

                    //if owner deleted the room then show this dialog
                    if (!state.isRoomExist) {
                      if (context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId !=
                          state.battleRoom.user1!.uid) {
                        //Room destroyed by owner
                        showRoomDestroyed(context);
                      }
                    }
                  }
                },
                child: LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    children: [
                      Container(
                        height: constraints.maxHeight * (0.10),
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(UiUtils.dialogRadius),
                            topRight: Radius.circular(UiUtils.dialogRadius),
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "${AppLocalization.of(context)!.getTranslatedValues('entryAmountLbl')!} : ${context.read<MultiUserBattleRoomCubit>().getEntryFee()}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    onPressed: () {
                                      try {
                                        String inviteMessage =
                                            "$groupBattleInviteMessage${context.read<MultiUserBattleRoomCubit>().getRoomCode()}";
                                        Share.share(inviteMessage);
                                      } catch (e) {
                                        UiUtils.setSnackbar(
                                            AppLocalization.of(context)!
                                                .getTranslatedValues(
                                                    convertErrorCodeToLanguageKey(
                                                        defaultErrorMessageCode))!,
                                            context,
                                            false);
                                      }
                                    },
                                    iconSize: 20,
                                    icon: const Icon(Icons.share),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                  ))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.025),
                      ),
                      Container(
                        width: constraints.maxWidth * (0.85),
                        height: constraints.maxHeight * (0.175),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    //
                                    child: Text(
                                        "${AppLocalization.of(context)!.getTranslatedValues('roomCodeLbl')!} : ${context.read<MultiUserBattleRoomCubit>().getRoomCode()}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          height: 1.2,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                                AppLocalization.of(context)!
                                    .getTranslatedValues('shareRoomCodeLbl')!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13.5,
                                  height: 1.2,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.0275),
                      ),
                      BlocBuilder<MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState>(
                        bloc: context.read<MultiUserBattleRoomCubit>(),
                        builder: (context, state) {
                          if (state is MultiUserBattleRoomSuccess) {
                            return profileAndNameContainer(
                                context,
                                constraints,
                                state.battleRoom.user1!.name,
                                state.battleRoom.user1!.profileUrl,
                                Theme.of(context).colorScheme.background);
                          }
                          return profileAndNameContainer(context, constraints,
                              "", "", Theme.of(context).colorScheme.background);
                        },
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.027),
                      ),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          AppLocalization.of(context)!
                              .getTranslatedValues('vsLbl')!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.background),
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.0125),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: BlocBuilder<MultiUserBattleRoomCubit,
                            MultiUserBattleRoomState>(
                          bloc: context.read<MultiUserBattleRoomCubit>(),
                          builder: (context, state) {
                            if (state is MultiUserBattleRoomSuccess) {
                              return widget.quizType == QuizTypes.battle
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        profileAndNameContainer(
                                            context,
                                            constraints,
                                            state.battleRoom.user2!.name,
                                            state.battleRoom.user2!.profileUrl,
                                            Colors.black54),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        profileAndNameContainer(
                                            context,
                                            constraints,
                                            state.battleRoom.user2!.name,
                                            state.battleRoom.user2!.profileUrl,
                                            Colors.black54),
                                        profileAndNameContainer(
                                            context,
                                            constraints,
                                            state.battleRoom.user3!.name,
                                            state.battleRoom.user3!.profileUrl,
                                            Colors.black54),
                                        profileAndNameContainer(
                                            context,
                                            constraints,
                                            state.battleRoom.user4!.name,
                                            state.battleRoom.user4!.profileUrl,
                                            Colors.black54),
                                      ],
                                    );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                      const Spacer(),
                      BlocBuilder<MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState>(
                        bloc: context.read<MultiUserBattleRoomCubit>(),
                        builder: (context, state) {
                          if (state is MultiUserBattleRoomSuccess) {
                            if (state.battleRoom.user1!.uid !=
                                context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile()
                                    .userId) {
                              return Container();
                            }
                            return TextButton(
                              onPressed: () {
                                //need minimum 2 player to start the game
                                //mark as ready to play in database
                                if (state.battleRoom.user2!.uid.isEmpty) {
                                  UiUtils.errorMessageDialog(
                                      context,
                                      AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              convertErrorCodeToLanguageKey(
                                                  canNotStartGameCode)));
                                } else {
                                  //start quiz
                                  /*    widget.quizType==QuizTypes.battle?context.read<BattleRoomCubit>().startGame():*/ context
                                      .read<MultiUserBattleRoomCubit>()
                                      .startGame();
                                  //navigate to quiz screen
                                  widget.quizType == QuizTypes.battle
                                      ? Navigator.of(context)
                                          .pushReplacementNamed(
                                              Routes.battleRoomQuiz,
                                              arguments: {
                                              "battleLbl": widget.battleLbl,
                                              "isTournamentBattle": false
                                            })
                                      : Navigator.of(context)
                                          .pushReplacementNamed(
                                              Routes.multiUserBattleRoomQuiz);
                                }
                              },
                              child: Text(
                                  AppLocalization.of(context)!
                                      .getTranslatedValues('startLbl')!,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: Theme.of(context).primaryColor)),
                            );
                          }
                          return Container();
                        },
                      ),
                      SizedBox(
                        height: constraints.maxHeight * (0.01),
                      ),
                    ],
                  );
                }),
              ),
      ),
    );
  }
}
