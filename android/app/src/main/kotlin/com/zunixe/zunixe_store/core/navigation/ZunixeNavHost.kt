package com.zunixe.zunixe_store.core.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.zunixe.zunixe_store.feature.auth.ui.AccountScreen
import com.zunixe.zunixe_store.feature.auth.ui.AuthViewModel
import com.zunixe.zunixe_store.feature.auth.ui.LoginScreen
import com.zunixe.zunixe_store.feature.auth.ui.RegisterScreen
import com.zunixe.zunixe_store.feature.auth.ui.ResetPasswordScreen
import com.zunixe.zunixe_store.feature.cart.ui.AddToCartButton
import com.zunixe.zunixe_store.feature.cart.ui.CartScreen
import com.zunixe.zunixe_store.feature.cart.ui.CartViewModel
import com.zunixe.zunixe_store.feature.catalog.ui.ProductDetailScreen
import com.zunixe.zunixe_store.feature.catalog.ui.ProductsScreen
import com.zunixe.zunixe_store.feature.checkout.ui.CheckoutScreen
import com.zunixe.zunixe_store.feature.checkout.ui.OrderSuccessScreen
import com.zunixe.zunixe_store.feature.home.ui.HomeScreen
import com.zunixe.zunixe_store.feature.home.ui.MainShell
import com.zunixe.zunixe_store.feature.orders.ui.OrdersScreen
import com.zunixe.zunixe_store.feature.support.ui.AboutScreen
import com.zunixe.zunixe_store.feature.support.ui.ChatScreen
import com.zunixe.zunixe_store.feature.support.ui.LegalScreen

/** NavHost aplikasi lengkap dengan guard auth. */
@Composable
fun ZunixeNavHost(
    navController: NavHostController = rememberNavController(),
    authViewModel: AuthViewModel = hiltViewModel(),
    cartViewModel: CartViewModel = hiltViewModel(),
) {
    val auth by authViewModel.state.collectAsState()
    val cart by cartViewModel.state.collectAsState()

    // Buttons utk menambah ke keranjang (dipakai di katalog & detail).
    val addToCart: @Composable (com.zunixe.zunixe_store.feature.catalog.domain.Product) -> Unit = { product ->
        val scope = androidx.compose.runtime.rememberCoroutineScope()
        AddToCartButton(
            product = product,
            compact = false,
            expand = true,
            onAdd = { id -> cartViewModel.addToCart(id) },
        )
    }

    NavHost(navController = navController, startDestination = Routes.HOME) {

        composable(Routes.HOME) {
            MainShell(
                cartCount = cart.itemCount,
                screens = listOf(
                    {
                        HomeScreen(
                            cartCount = cart.itemCount,
                            onSearch = { navController.navigate(Routes.PRODUCTS) },
                            onCart = { navController.navigate(Routes.CART) },
                            onProfile = {
                                navController.navigate(if (auth.isLoggedIn) Routes.ACCOUNT else Routes.LOGIN)
                            },
                            onProducts = { navController.navigate(Routes.PRODUCTS) },
                            onProductClick = { p ->
                                navController.navigate(Routes.productDetail(p.id))
                            },
                            onAbout = { navController.navigate(Routes.ABOUT) },
                            onLegal = { slug -> navController.navigate(Routes.legal(slug)) },
                            addButton = addToCart,
                        )
                    },
                    {
                        ProductsScreen(
                            showBack = false,
                            cartCount = cart.itemCount,
                            onBack = {},
                            onCart = { navController.navigate(Routes.CART) },
                            onProductClick = { p ->
                                navController.navigate(Routes.productDetail(p.id))
                            },
                            addButton = addToCart,
                        )
                    },
                    {
                        CartScreen(
                            onSwitchToProduk = { navController.navigate(Routes.PRODUCTS) },
                            onCheckout = { navController.navigate(Routes.CHECKOUT) },
                        )
                    },
                    {
                        AccountScreen(
                            onGoOrders = { navController.navigate(Routes.ORDERS) },
                            onGoCart = { navController.navigate(Routes.CART) },
                            onGoChat = { navController.navigate(Routes.CHAT) },
                            onGoAbout = { navController.navigate(Routes.ABOUT) },
                        )
                    },
                    { ChatScreen() },
                ),
            )
        }

        composable(Routes.PRODUCTS) {
            ProductsScreen(
                showBack = true,
                cartCount = cart.itemCount,
                onBack = { navController.popBackStack() },
                onCart = { navController.navigate(Routes.CART) },
                onProductClick = { p -> navController.navigate(Routes.productDetail(p.id)) },
                addButton = addToCart,
            )
        }

        composable(
            route = Routes.PRODUCT_DETAIL,
            arguments = listOf(navArgument("productId") { type = NavType.StringType }),
        ) { entry ->
            ProductDetailScreen(
                productId = entry.arguments?.getString("productId"),
                initialProduct = null,
                cartCount = cart.itemCount,
                onBack = { navController.popBackStack() },
                onCart = { navController.navigate(Routes.CART) },
                addButton = addToCart,
            )
        }

        composable(Routes.CART) {
            CartScreen(
                onSwitchToProduk = { navController.popBackStack() },
                onCheckout = { navController.navigate(Routes.CHECKOUT) },
            )
        }

        composable(Routes.LOGIN) {
            LoginScreen(
                onBack = { navController.popBackStack() },
                onLoggedIn = { navController.popBackStack() },
                onGoRegister = { navController.navigate(Routes.REGISTER) },
            )
        }

        composable(Routes.REGISTER) {
            RegisterScreen(
                onBack = { navController.popBackStack() },
                onDoneLoggedIn = { navController.popBackStack() },
                onNeedVerification = {
                    navController.navigate(Routes.LOGIN) {
                        popUpTo(Routes.REGISTER) { inclusive = true }
                    }
                },
            )
        }

        composable(Routes.RESET_PASSWORD) {
            ResetPasswordScreen(onDone = {
                navController.navigate(Routes.HOME) { popUpTo(Routes.HOME) { inclusive = true } }
            })
        }

        composable(Routes.ACCOUNT) {
            if (!auth.isLoggedIn) {
                LoginScreen(
                    onBack = { navController.popBackStack() },
                    onLoggedIn = { navController.popBackStack() },
                    onGoRegister = { navController.navigate(Routes.REGISTER) },
                )
            } else {
                AccountScreen(
                    onGoOrders = { navController.navigate(Routes.ORDERS) },
                    onGoCart = { navController.navigate(Routes.CART) },
                    onGoChat = { navController.navigate(Routes.CHAT) },
                    onGoAbout = { navController.navigate(Routes.ABOUT) },
                )
            }
        }

        composable(Routes.CHECKOUT) {
            if (!auth.isLoggedIn) {
                LoginScreen(
                    onBack = { navController.popBackStack() },
                    onLoggedIn = { },
                    onGoRegister = { navController.navigate(Routes.REGISTER) },
                )
            } else {
                CheckoutScreen(
                    onBack = { navController.popBackStack() },
                    onSuccess = { code, total ->
                        navController.navigate(Routes.orderSuccess(code, total)) {
                            popUpTo(Routes.CART) { inclusive = true }
                        }
                    },
                    onNeedLogin = { navController.navigate(Routes.LOGIN) },
                )
            }
        }

        composable(
            route = Routes.ORDER_SUCCESS,
            arguments = listOf(
                navArgument("orderCode") { type = NavType.StringType },
                navArgument("total") { type = NavType.StringType },
            ),
        ) { entry ->
            OrderSuccessScreen(
                orderCode = entry.arguments?.getString("orderCode") ?: "-",
                total = entry.arguments?.getString("total")?.toIntOrNull() ?: 0,
                onViewOrders = { navController.navigate(Routes.ORDERS) },
                onBackHome = {
                    navController.navigate(Routes.HOME) { popUpTo(Routes.HOME) { inclusive = true } }
                },
            )
        }

        composable(Routes.ORDERS) {
            if (!auth.isLoggedIn) {
                LoginScreen(
                    onBack = { navController.popBackStack() },
                    onLoggedIn = { },
                    onGoRegister = { navController.navigate(Routes.REGISTER) },
                )
            } else {
                OrdersScreen(
                    onBack = { navController.popBackStack() },
                    onLogin = { navController.navigate(Routes.LOGIN) },
                )
            }
        }

        composable(Routes.CHAT) {
            ChatScreen()
        }

        composable(Routes.ABOUT) {
            AboutScreen(onBack = { navController.popBackStack() })
        }

        composable(
            route = Routes.LEGAL,
            arguments = listOf(navArgument("slug") { type = NavType.StringType }),
        ) { entry ->
            LegalScreen(
                slug = entry.arguments?.getString("slug") ?: "tos",
                onBack = { navController.popBackStack() },
            )
        }
    }
}
