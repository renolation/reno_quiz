import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/inAppPurchase/inAppPurchaseCubit.dart';
import 'package:flutterquiz/features/inAppPurchase/in_app_product.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class CoinStoreScreen extends StatefulWidget {
  const CoinStoreScreen({
    required this.isGuest,
    required this.iapProducts,
    super.key,
  });

  final bool isGuest;
  final List<InAppProduct> iapProducts;

  @override
  State<CoinStoreScreen> createState() => _CoinStoreScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments! as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<InAppPurchaseCubit>(create: (_) => InAppPurchaseCubit()),
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: CoinStoreScreen(
          isGuest: args['isGuest'] as bool,
          iapProducts: args['iapProducts'] as List<InAppProduct>,
        ),
      ),
    );
  }
}

class _CoinStoreScreenState extends State<CoinStoreScreen>
    with SingleTickerProviderStateMixin {
  List<String> productIds = [];

  @override
  void initState() {
    super.initState();
    productIds = widget.iapProducts.map((e) => e.productId).toSet().toList();
  }

  void initPurchase() {
    context.read<InAppPurchaseCubit>().initializePurchase(
          productIds,
          userAlreadyRemovedAds: context.read<UserDetailsCubit>().removeAds(),
        );
  }

  Widget _buildProducts(List<ProductDetails> products) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> restorePurchases() async {
      return context.read<InAppPurchaseCubit>().restorePurchases();
    }

    return Stack(
      children: [
        GridView.builder(
          padding: EdgeInsets.symmetric(
            vertical: size.height * UiUtils.vtMarginPct,
            horizontal: size.width * UiUtils.hzMarginPct,
          ),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, idx) {
            final product = products[idx];
            final iap = widget.iapProducts
                .where((e) => e.productId == product.id)
                .first;

            void purchaseProduct() {
              if (context.read<InAppPurchaseCubit>().state
                  is InAppPurchaseProcessInProgress) return;

              if (widget.isGuest) {
                showLoginDialog(
                  context,
                  onTapYes: () {
                    context
                      ..shouldPop() // close dialog
                      ..shouldPop() // menu screen
                      ..pushNamed(Routes.login);
                  },
                );
                return;
              }

              context.read<InAppPurchaseCubit>().buyConsumableProducts(product);
            }

            return GestureDetector(
              onTap: purchaseProduct,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 15),
                      child: iap.image.endsWith('.svg')
                          ? SvgPicture.network(
                              iap.image,
                              width: 40,
                              height: 26,
                            )
                          : Image.network(
                              iap.image,
                              width: 40,
                              height: 26,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        iap.desc,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onTertiary.withOpacity(0.4),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      iap.title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onTertiary,
                        fontWeight: FontWeights.semiBold,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 4,
                      ),
                      child: Text(
                        product.price,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeights.semiBold,
                          color: colorScheme.onTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),

        /// Restore Button
        if (Platform.isIOS && !widget.isGuest)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
              child: CustomRoundedButton(
                widthPercentage: 1,
                backgroundColor: Theme.of(context).primaryColor,
                buttonTitle: context.tr('restorePurchaseProducts'),
                radius: 8,
                showBorder: false,
                fontWeight: FontWeights.semiBold,
                height: 58,
                titleColor: colorScheme.background,
                onTap: restorePurchases,
                elevation: 6.5,
                textSize: 18,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    initPurchase();

    return PopScope(
      canPop: context.read<InAppPurchaseCubit>().state
          is! InAppPurchaseProcessInProgress,
      child: Scaffold(
        appBar: QAppBar(
          title: Text(
            context.tr(coinStoreKey)!,
          ),
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: BlocConsumer<InAppPurchaseCubit, InAppPurchaseState>(
                bloc: context.read<InAppPurchaseCubit>(),
                listener: (context, state) {
                  log('State change to $state');

                  if (state is InAppPurchaseProcessSuccess) {
                    final iap = widget.iapProducts.firstWhere(
                      (e) => e.productId == state.purchasedProductId,
                    );

                    /// Remove Ads if IAP is remove_ads
                    if (state.purchasedProductId == removeAdsProductId) {
                      // Update Values Remotely & Locally.
                      context
                          .read<UpdateUserDetailCubit>()
                          .removeAdsForUser(status: true);
                      context
                          .read<UserDetailsCubit>()
                          .updateUserProfile(adsRemovedForUser: '1');

                      state.products.removeWhere(
                        (e) => e.id == removeAdsProductId,
                      );
                      widget.iapProducts.removeWhere(
                        (e) => e.productId == removeAdsProductId,
                      );
                    } else {
                      context
                          .read<UserDetailsCubit>()
                          .updateCoins(addCoin: true, coins: iap.coins);
                      context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                            coins: iap.coins,
                            addCoin: true,
                            title: boughtCoinsKey,
                          );
                    }

                    UiUtils.showSnackBar(
                      "${iap.title} ${context.tr("boughtSuccess")!}",
                      context,
                    );
                  } else if (state is InAppPurchaseProcessFailure) {
                    UiUtils.showSnackBar(
                      context.tr(state.errorMessage)!,
                      context,
                    );
                  }
                },
                builder: (context, state) {
                  //initial state of cubit
                  if (state is InAppPurchaseInitial ||
                      state is InAppPurchaseLoading) {
                    return const Center(child: CircularProgressContainer());
                  }

                  //if occurred problem while fetching product details
                  //from appstore or playstore
                  if (state is InAppPurchaseFailure) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: false,
                        errorMessage: state.errorMessage,
                        onTapRetry: initPurchase,
                        showErrorImage: true,
                      ),
                    );
                  }

                  if (state is InAppPurchaseNotAvailable) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: false,
                        errorMessage: inAppPurchaseUnavailableKey,
                        onTapRetry: initPurchase,
                        showErrorImage: true,
                      ),
                    );
                  }

                  //if any error occurred in while making in-app purchase
                  if (state is InAppPurchaseProcessFailure) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseAvailable) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseProcessSuccess) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseProcessInProgress) {
                    return _buildProducts(state.products);
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
