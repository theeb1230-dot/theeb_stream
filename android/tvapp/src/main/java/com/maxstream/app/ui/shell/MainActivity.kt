package com.maxstream.app.ui.shell

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusProperties
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.key.Key
import androidx.compose.ui.input.key.KeyEventType
import androidx.compose.ui.input.key.key
import androidx.compose.ui.input.key.onKeyEvent
import androidx.compose.ui.input.key.type
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.maxstream.app.data.local.WatchEntryCompat
import com.maxstream.app.ui.navigation.Screen
import com.maxstream.app.ui.screens.details.DetailsScreen
import com.maxstream.app.ui.screens.genre.GenreScreen
import com.maxstream.app.ui.screens.home.HomeScreen
import com.maxstream.app.ui.screens.more.MoreScreen
import com.maxstream.app.ui.screens.player.PlayerScreen
import com.maxstream.app.ui.screens.search.SearchScreen
import com.maxstream.app.ui.screens.series.SeriesListScreen
import com.maxstream.app.ui.screens.splash.SplashScreen
import com.maxstream.app.ui.screens.watchlist.WatchlistScreen
import com.maxstream.app.ui.theme.TheebStreamTheme
import com.maxstream.app.ui.tv.TvFocusManager

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        WatchEntryCompat.init(applicationContext)
        try {
            setContent { TheebStreamTheme { TvAppRoot() } }
        } catch (t: Throwable) {
            Log.e("MainActivity", "Compose startup failure", t)
        }
    }
}

@Composable
private fun TvAppRoot() {
    val appState = rememberTvAppState()
    val sidebarFocusRequesters = remember { List(6) { FocusRequester() } }
    val contentFocusRequester = remember { FocusRequester() }
    val shellNavController = rememberNavController()
    val deepNavController = rememberNavController()

    LaunchedEffect(Unit) {
        TvFocusManager.initialize(
            sidebarFocusRequesters = sidebarFocusRequesters,
            contentFocusRequester = contentFocusRequester,
        )
    }

    var exitDialogVisible by remember { mutableStateOf(false) }
    var contentFocusTick by remember { mutableIntStateOf(0) }
    var deepNavReturnTick by remember { mutableIntStateOf(0) }

    LaunchedEffect(Unit) {
        var prev: String? = Screen.DeepRoot.route
        deepNavController.currentBackStackEntryFlow.collect { entry ->
            val route = entry.destination.route
            if (route == Screen.DeepRoot.route && prev != Screen.DeepRoot.route) {
                deepNavReturnTick++
            }
            prev = route
        }
    }

    fun handleBack() {
        if (deepNavController.currentBackStackEntry?.destination?.route != Screen.DeepRoot.route) {
            deepNavController.popBackStack()
            return
        }
        if (appState.selectedTab == 0) {
            if (appState.focusOnSidebar) {
                exitDialogVisible = true
            } else {
                appState.updateFocusOnSidebar(true)
            }
            return
        }
        appState.selectTab(0)
        appState.updateFocusOnSidebar(true)
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0F0F0F))
            .onKeyEvent { event ->
                if (event.type == KeyEventType.KeyDown &&
                    (event.key == Key.Back || event.key == Key.Escape)
                ) {
                    handleBack()
                    true
                } else {
                    false
                }
            },
    ) {
        NavHost(
            navController = shellNavController,
            startDestination = Screen.Splash.route,
            enterTransition = { fadeIn(tween(300)) },
            exitTransition = { fadeOut(tween(180)) },
            popEnterTransition = { fadeIn(tween(250)) },
            popExitTransition = { fadeOut(tween(200)) },
        ) {
            composable(Screen.Splash.route) {
                SplashScreen(onComplete = {
                    shellNavController.navigate(Screen.Shell.route) {
                        popUpTo(Screen.Splash.route) { inclusive = true }
                    }
                })
            }
            composable(Screen.Shell.route) {
                TvShell(
                    appState = appState,
                    sidebarFocusRequesters = sidebarFocusRequesters,
                    contentFocusRequester = contentFocusRequester,
                    shellNavController = shellNavController,
                    deepNavController = deepNavController,
                    contentFocusTick = contentFocusTick,
                    deepNavReturnTick = deepNavReturnTick,
                    requestContentFocus = { contentFocusTick++ },
                )
            }
        }

        NavHost(
            navController = deepNavController,
            startDestination = Screen.DeepRoot.route,
            enterTransition = { fadeIn(tween(250)) },
            exitTransition = { fadeOut(tween(180)) },
            popEnterTransition = { fadeIn(tween(220)) },
            popExitTransition = { fadeOut(tween(200)) },
        ) {
            composable(Screen.DeepRoot.route) {
                Box(Modifier.fillMaxSize())
            }
            composable(Screen.Details.route) { backStackEntry ->
                val itemId = backStackEntry.arguments?.getString("itemId") ?: ""
                val mediaType = backStackEntry.arguments?.getString("mediaType") ?: "movie"
                DetailsScreen(
                    navController = deepNavController,
                    itemId = itemId,
                    mediaType = mediaType,
                    onReturnToSidebar = {
                        deepNavController.popBackStack()
                    },
                )
            }
            composable(Screen.Player.route) { backStackEntry ->
                val itemId = backStackEntry.arguments?.getString("itemId") ?: ""
                val mediaType = backStackEntry.arguments?.getString("mediaType") ?: "movie"
                val season = backStackEntry.arguments?.getString("season")?.toIntOrNull() ?: 1
                val episode = backStackEntry.arguments?.getString("episode")?.toIntOrNull() ?: 1
                PlayerScreen(deepNavController, itemId, mediaType, season, episode)
            }
        }

        if (exitDialogVisible) {
            val activity = androidx.compose.ui.platform.LocalContext.current as? android.app.Activity
            ExitDialog(
                onDismiss = { exitDialogVisible = false },
                onConfirm = {
                    exitDialogVisible = false
                    activity?.finish()
                },
            )
        }
    }
}

@Composable
private fun TvShell(
    appState: TvAppState,
    sidebarFocusRequesters: List<FocusRequester>,
    contentFocusRequester: FocusRequester,
    shellNavController: androidx.navigation.NavController,
    deepNavController: androidx.navigation.NavController,
    contentFocusTick: Int,
    deepNavReturnTick: Int,
    requestContentFocus: () -> Unit,
) {
    Row(modifier = Modifier.fillMaxSize()) {
        Sidebar(
            selectedIndex = appState.selectedTab,
            focusRequesters = sidebarFocusRequesters,
            onItemSelected = { index -> appState.selectTab(index) },
            onReturnToContent = {
                appState.updateFocusOnSidebar(false)
                requestContentFocus()
            },
            onFocusEntered = { appState.updateFocusOnSidebar(true) },
            active = appState.focusOnSidebar,
        )

        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxSize()
                .focusRequester(contentFocusRequester)
                .onFocusChanged { state ->
                    if (state.hasFocus) appState.updateFocusOnSidebar(false)
                },
        ) {
            TabScreen(visible = appState.selectedTab == 0) {
                HomeScreen(
                    navController = deepNavController,
                    onReturnToSidebar = { appState.updateFocusOnSidebar(true) },
                    isVisible = appState.selectedTab == 0,
                    focusKey = contentFocusTick,
                    restoreFocusKey = deepNavReturnTick,
                )
            }
            TabScreen(visible = appState.selectedTab == 1) {
                SearchScreen(
                    navController = deepNavController,
                    onReturnToSidebar = { appState.updateFocusOnSidebar(true) },
                    isVisible = appState.selectedTab == 1,
                    focusKey = contentFocusTick,
                    restoreFocusKey = deepNavReturnTick,
                )
            }
            TabScreen(visible = appState.selectedTab == 2) {
                GenreScreen(
                    navController = deepNavController,
                    onReturnToSidebar = { appState.updateFocusOnSidebar(true) },
                    isVisible = appState.selectedTab == 2,
                    focusKey = contentFocusTick,
                    restoreFocusKey = deepNavReturnTick,
                )
            }
            TabScreen(visible = appState.selectedTab == 3) {
                SeriesListTab(
                    navController = deepNavController,
                    onReturnToSidebar = { appState.updateFocusOnSidebar(true) },
                    isVisible = appState.selectedTab == 3,
                    focusKey = contentFocusTick,
                    restoreFocusKey = deepNavReturnTick,
                )
            }
            TabScreen(visible = appState.selectedTab == 4) {
                WatchlistScreen(
                    navController = deepNavController,
                    onReturnToSidebar = { appState.updateFocusOnSidebar(true) },
                    isVisible = appState.selectedTab == 4,
                    focusKey = contentFocusTick,
                    restoreFocusKey = deepNavReturnTick,
                )
            }
            TabScreen(visible = appState.selectedTab == 5) {
                MoreScreen(
                    navController = deepNavController,
                    onReturnToSidebar = { appState.updateFocusOnSidebar(true) },
                    isVisible = appState.selectedTab == 5,
                    focusKey = contentFocusTick,
                    restoreFocusKey = deepNavReturnTick,
                )
            }
        }
    }
}

@Composable
private fun TabScreen(
    visible: Boolean,
    content: @Composable () -> Unit,
) {
    androidx.compose.animation.AnimatedVisibility(
        visible = visible,
        enter = androidx.compose.animation.fadeIn(tween(220)),
        exit = androidx.compose.animation.fadeOut(tween(160)),
    ) {
        Box(modifier = Modifier.fillMaxSize()) {
            content()
        }
    }
}

@Composable
private fun SeriesListTab(
    navController: androidx.navigation.NavController,
    onReturnToSidebar: () -> Unit,
    isVisible: Boolean,
    focusKey: Int,
    restoreFocusKey: Int,
) {
    SeriesListScreen(
        navController = navController,
        onReturnToSidebar = onReturnToSidebar,
        isVisible = isVisible,
        focusKey = focusKey,
        restoreFocusKey = restoreFocusKey,
    )
}

@Composable
private fun ExitDialog(onDismiss: () -> Unit, onConfirm: () -> Unit) {
    val cancelFocus = remember { FocusRequester() }
    val confirmFocus = remember { FocusRequester() }
    var cancelFocused by remember { mutableStateOf(false) }
    var confirmFocused by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) { cancelFocus.requestFocus() }
    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = Color(0xFF1E1E1E),
        title = {
            Text(
                "الخروج من ذيب ستريم؟",
                color = Color.White,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
            )
        },
        text = {
            Text(
                "هل تريد الخروج من التطبيق؟",
                color = Color.White.copy(alpha = 0.7f),
                fontSize = 18.sp,
            )
        },
        dismissButton = {
            TextButton(
                modifier = Modifier
                    .focusRequester(cancelFocus)
                    .focusProperties {
                        left = confirmFocus
                        right = confirmFocus
                    }
                    .onFocusChanged { cancelFocused = it.isFocused }
                    .background(
                        if (cancelFocused) Color.White else Color.Transparent,
                        RoundedCornerShape(20.dp),
                    )
                    .border(
                        width = if (cancelFocused) 2.dp else 1.dp,
                        color = if (cancelFocused) Color.White else Color(0x40FFFFFF),
                        shape = RoundedCornerShape(20.dp),
                    ),
                onClick = onDismiss,
                colors = ButtonDefaults.textButtonColors(
                    contentColor = if (cancelFocused) Color.Black else Color.White,
                ),
            ) {
                Text(
                    "إلغاء",
                    fontSize = 18.sp,
                    fontWeight = if (cancelFocused) FontWeight.Bold else FontWeight.Normal,
                )
            }
        },
        confirmButton = {
            TextButton(
                modifier = Modifier
                    .focusRequester(confirmFocus)
                    .focusProperties {
                        left = cancelFocus
                        right = cancelFocus
                    }
                    .onFocusChanged { confirmFocused = it.isFocused }
                    .background(
                        if (confirmFocused) Color.White else Color(0xFFE50914),
                        RoundedCornerShape(20.dp),
                    )
                    .border(
                        width = if (confirmFocused) 2.dp else 0.dp,
                        color = if (confirmFocused) Color.White else Color.Transparent,
                        shape = RoundedCornerShape(20.dp),
                    ),
                onClick = onConfirm,
                colors = ButtonDefaults.textButtonColors(
                    contentColor = if (confirmFocused) Color.Black else Color.White,
                ),
            ) {
                Text(
                    "خروج",
                    fontSize = 18.sp,
                    fontWeight = if (confirmFocused) FontWeight.Bold else FontWeight.Normal,
                )
            }
        },
    )
}
