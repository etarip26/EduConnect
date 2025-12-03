# ============================
# setup_structure.ps1
# Clean Architecture Flutter structure for EduConnect
# ============================

$baseDir = "E:\STUDY\Test_app"

if (!(Test-Path $baseDir)) {
    Write-Error "Base directory not found: $baseDir"
    exit 1
}

Write-Host "Using base directory: $baseDir"

function New-DirSafe {
    param([string]$path)
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

function New-FileSafe {
    param([string]$path)
    if (!(Test-Path $path)) {
        $dir = Split-Path $path -Parent
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
        }
        New-Item -ItemType File -Path $path | Out-Null
    }
}

# Root lib and src
$libDir     = Join-Path $baseDir "lib"
$srcDir     = Join-Path $libDir  "src"
$assetsDir  = Join-Path $baseDir "assets"

New-DirSafe $libDir
New-DirSafe $srcDir
New-DirSafe (Join-Path $assetsDir "images")
New-DirSafe (Join-Path $assetsDir "icons")
New-DirSafe (Join-Path $assetsDir "fonts")

# ============================
# Core app & config
# ============================

$cfgDir         = Join-Path $srcDir "config"
$coreDir        = Join-Path $srcDir "core"
$coreConstDir   = Join-Path $coreDir "constants"
$coreUtilsDir   = Join-Path $coreDir "utils"
$coreErrorDir   = Join-Path $coreDir "error"
$coreNetworkDir = Join-Path $coreDir "network"
$coreWidgetsDir = Join-Path $coreDir "widgets"
$coreServicesDir= Join-Path $coreDir "services"
$coreModelsDir  = Join-Path $coreDir "models"
$routingDir     = Join-Path $srcDir "routing"
$featuresDir    = Join-Path $srcDir "features"
$sharedDir      = Join-Path $srcDir "shared"

New-DirSafe $cfgDir
New-DirSafe $coreDir
New-DirSafe $coreConstDir
New-DirSafe $coreUtilsDir
New-DirSafe $coreErrorDir
New-DirSafe $coreNetworkDir
New-DirSafe $coreWidgetsDir
New-DirSafe $coreServicesDir
New-DirSafe $coreModelsDir
New-DirSafe $routingDir
New-DirSafe $featuresDir
New-DirSafe $sharedDir

# Core app files
New-FileSafe (Join-Path $libDir "main.dart")
New-FileSafe (Join-Path $srcDir "app.dart")

# Config
New-FileSafe (Join-Path $cfgDir "app_config.dart")
New-FileSafe (Join-Path $cfgDir "env.dart")
New-FileSafe (Join-Path $cfgDir "api_paths.dart")
New-FileSafe (Join-Path $cfgDir "app_theme.dart")
New-FileSafe (Join-Path $cfgDir "app_localization.dart")

# Routing
New-FileSafe (Join-Path $routingDir "app_router.dart")
New-FileSafe (Join-Path $routingDir "app_routes.dart")
New-FileSafe (Join-Path $routingDir "route_guard.dart")

# Core constants
New-FileSafe (Join-Path $coreConstDir "app_colors.dart")
New-FileSafe (Join-Path $coreConstDir "app_typography.dart")
New-FileSafe (Join-Path $coreConstDir "app_spacing.dart")
New-FileSafe (Join-Path $coreConstDir "app_assets.dart")
New-FileSafe (Join-Path $coreConstDir "app_roles.dart")

# Core utils
New-FileSafe (Join-Path $coreUtilsDir "validators.dart")
New-FileSafe (Join-Path $coreUtilsDir "formatters.dart")
New-FileSafe (Join-Path $coreUtilsDir "date_time_utils.dart")
New-FileSafe (Join-Path $coreUtilsDir "debouncer.dart")
New-FileSafe (Join-Path $coreUtilsDir "snackbar_utils.dart")

# Core error
New-FileSafe (Join-Path $coreErrorDir "exceptions.dart")
New-FileSafe (Join-Path $coreErrorDir "failures.dart")
New-FileSafe (Join-Path $coreErrorDir "error_mapper.dart")

# Core network
New-FileSafe (Join-Path $coreNetworkDir "api_client.dart")
New-FileSafe (Join-Path $coreNetworkDir "network_info.dart")
New-FileSafe (Join-Path $coreNetworkDir "interceptors.dart")
New-FileSafe (Join-Path $coreNetworkDir "api_response.dart")

# Core widgets
New-FileSafe (Join-Path $coreWidgetsDir "app_scaffold.dart")
New-FileSafe (Join-Path $coreWidgetsDir "app_button.dart")
New-FileSafe (Join-Path $coreWidgetsDir "app_text_field.dart")
New-FileSafe (Join-Path $coreWidgetsDir "app_dropdown.dart")
New-FileSafe (Join-Path $coreWidgetsDir "app_loading_indicator.dart")
New-FileSafe (Join-Path $coreWidgetsDir "app_empty_state.dart")
New-FileSafe (Join-Path $coreWidgetsDir "app_error_view.dart")
New-FileSafe (Join-Path $coreWidgetsDir "app_avatar.dart")
New-FileSafe (Join-Path $coreWidgetsDir "app_badge.dart")
New-FileSafe (Join-Path $coreWidgetsDir "app_bottom_nav_bar.dart")

# Core services
New-FileSafe (Join-Path $coreServicesDir "auth_service.dart")
New-FileSafe (Join-Path $coreServicesDir "storage_service.dart")
New-FileSafe (Join-Path $coreServicesDir "notification_service.dart")
New-FileSafe (Join-Path $coreServicesDir "deep_link_service.dart")
New-FileSafe (Join-Path $coreServicesDir "navigation_service.dart")

# Core models (global/shared models)
New-FileSafe (Join-Path $coreModelsDir "user_model.dart")
New-FileSafe (Join-Path $coreModelsDir "student_profile_model.dart")
New-FileSafe (Join-Path $coreModelsDir "teacher_profile_model.dart")
New-FileSafe (Join-Path $coreModelsDir "tuition_post_model.dart")
New-FileSafe (Join-Path $coreModelsDir "tuition_application_model.dart")
New-FileSafe (Join-Path $coreModelsDir "demo_session_model.dart")
New-FileSafe (Join-Path $coreModelsDir "match_model.dart")
New-FileSafe (Join-Path $coreModelsDir "chat_room_model.dart")
New-FileSafe (Join-Path $coreModelsDir "chat_message_model.dart")
New-FileSafe (Join-Path $coreModelsDir "notification_model.dart")
New-FileSafe (Join-Path $coreModelsDir "review_model.dart")
New-FileSafe (Join-Path $coreModelsDir "paginated_result.dart")

# ============================
# Feature: Auth
# ============================

$authBase   = Join-Path $featuresDir "auth"
$authData   = Join-Path $authBase "data"
$authDomain = Join-Path $authBase "domain"
$authPres   = Join-Path $authBase "presentation"

New-DirSafe (Join-Path $authData   "datasources")
New-DirSafe (Join-Path $authData   "repositories")
New-DirSafe (Join-Path $authDomain "entities")
New-DirSafe (Join-Path $authDomain "repositories")
New-DirSafe (Join-Path $authDomain "usecases")
New-DirSafe (Join-Path $authPres   "bloc")
New-DirSafe (Join-Path $authPres   "pages")
New-DirSafe (Join-Path $authPres   "widgets")

# Auth data
New-FileSafe (Join-Path $authData "datasources/auth_remote_data_source.dart")
New-FileSafe (Join-Path $authData "repositories/auth_repository_impl.dart")

# Auth domain
New-FileSafe (Join-Path $authDomain "entities/auth_user.dart")
New-FileSafe (Join-Path $authDomain "repositories/auth_repository.dart")
New-FileSafe (Join-Path $authDomain "usecases/login_usecase.dart")
New-FileSafe (Join-Path $authDomain "usecases/register_usecase.dart")
New-FileSafe (Join-Path $authDomain "usecases/request_otp_usecase.dart")
New-FileSafe (Join-Path $authDomain "usecases/verify_otp_usecase.dart")
New-FileSafe (Join-Path $authDomain "usecases/get_current_user_usecase.dart")
New-FileSafe (Join-Path $authDomain "usecases/logout_usecase.dart")

# Auth presentation
New-FileSafe (Join-Path $authPres "bloc/auth_cubit.dart")
New-FileSafe (Join-Path $authPres "pages/splash_page.dart")
New-FileSafe (Join-Path $authPres "pages/onboarding_page.dart")
New-FileSafe (Join-Path $authPres "pages/login_page.dart")
New-FileSafe (Join-Path $authPres "pages/register_page.dart")
New-FileSafe (Join-Path $authPres "pages/otp_verification_page.dart")
New-FileSafe (Join-Path $authPres "widgets/login_form.dart")
New-FileSafe (Join-Path $authPres "widgets/register_form.dart")
New-FileSafe (Join-Path $authPres "widgets/otp_input_field.dart")

# ============================
# Feature: Dashboard / Home
# ============================

$dashBase = Join-Path $featuresDir "dashboard"
$dashPres = Join-Path $dashBase "presentation"

New-DirSafe (Join-Path $dashPres "pages")
New-DirSafe (Join-Path $dashPres "widgets")
New-DirSafe (Join-Path $dashPres "bloc")

New-FileSafe (Join-Path $dashPres "pages/dashboard_page.dart")
New-FileSafe (Join-Path $dashPres "pages/student_home_page.dart")
New-FileSafe (Join-Path $dashPres "pages/teacher_home_page.dart")
New-FileSafe (Join-Path $dashPres "pages/admin_home_page.dart")
New-FileSafe (Join-Path $dashPres "bloc/dashboard_cubit.dart")
New-FileSafe (Join-Path $dashPres "widgets/dashboard_header.dart")
New-FileSafe (Join-Path $dashPres "widgets/stats_overview_card.dart")

# ============================
# Feature: Profile (Student & Teacher)
# ============================

$profBase   = Join-Path $featuresDir "profile"
$profData   = Join-Path $profBase "data"
$profDomain = Join-Path $profBase "domain"
$profPres   = Join-Path $profBase "presentation"

New-DirSafe (Join-Path $profData   "datasources")
New-DirSafe (Join-Path $profData   "repositories")
New-DirSafe (Join-Path $profDomain "entities")
New-DirSafe (Join-Path $profDomain "repositories")
New-DirSafe (Join-Path $profDomain "usecases")
New-DirSafe (Join-Path $profPres   "bloc")
New-DirSafe (Join-Path $profPres   "pages")
New-DirSafe (Join-Path $profPres   "widgets")

# Profile data
New-FileSafe (Join-Path $profData "datasources/profile_remote_data_source.dart")
New-FileSafe (Join-Path $profData "repositories/profile_repository_impl.dart")

# Profile domain
New-FileSafe (Join-Path $profDomain "entities/student_profile.dart")
New-FileSafe (Join-Path $profDomain "entities/teacher_profile.dart")
New-FileSafe (Join-Path $profDomain "repositories/profile_repository.dart")
New-FileSafe (Join-Path $profDomain "usecases/get_student_profile_usecase.dart")
New-FileSafe (Join-Path $profDomain "usecases/update_student_profile_usecase.dart")
New-FileSafe (Join-Path $profDomain "usecases/get_teacher_profile_usecase.dart")
New-FileSafe (Join-Path $profDomain "usecases/update_teacher_profile_usecase.dart")

# Profile presentation
New-FileSafe (Join-Path $profPres "bloc/profile_cubit.dart")
New-FileSafe (Join-Path $profPres "pages/student_profile_page.dart")
New-FileSafe (Join-Path $profPres "pages/teacher_profile_page.dart")
New-FileSafe (Join-Path $profPres "pages/edit_student_profile_page.dart")
New-FileSafe (Join-Path $profPres "pages/edit_teacher_profile_page.dart")
New-FileSafe (Join-Path $profPres "widgets/profile_header.dart")
New-FileSafe (Join-Path $profPres "widgets/profile_form_student.dart")
New-FileSafe (Join-Path $profPres "widgets/profile_form_teacher.dart")

# ============================
# Feature: Tuition Posts
# ============================

$tpBase   = Join-Path $featuresDir "tuition_posts"
$tpData   = Join-Path $tpBase "data"
$tpDomain = Join-Path $tpBase "domain"
$tpPres   = Join-Path $tpBase "presentation"

New-DirSafe (Join-Path $tpData   "datasources")
New-DirSafe (Join-Path $tpData   "repositories")
New-DirSafe (Join-Path $tpDomain "entities")
New-DirSafe (Join-Path $tpDomain "repositories")
New-DirSafe (Join-Path $tpDomain "usecases")
New-DirSafe (Join-Path $tpPres   "bloc")
New-DirSafe (Join-Path $tpPres   "pages")
New-DirSafe (Join-Path $tpPres   "widgets")

# Tuition posts data
New-FileSafe (Join-Path $tpData "datasources/tuition_posts_remote_data_source.dart")
New-FileSafe (Join-Path $tpData "repositories/tuition_posts_repository_impl.dart")

# Tuition posts domain
New-FileSafe (Join-Path $tpDomain "entities/tuition_post.dart")
New-FileSafe (Join-Path $tpDomain "repositories/tuition_posts_repository.dart")
New-FileSafe (Join-Path $tpDomain "usecases/create_tuition_post_usecase.dart")
New-FileSafe (Join-Path $tpDomain "usecases/get_tuition_posts_usecase.dart")
New-FileSafe (Join-Path $tpDomain "usecases/get_my_tuition_posts_usecase.dart")
New-FileSafe (Join-Path $tpDomain "usecases/close_tuition_post_usecase.dart")

# Tuition posts presentation
New-FileSafe (Join-Path $tpPres "bloc/tuition_posts_cubit.dart")
New-FileSafe (Join-Path $tpPres "pages/tuition_posts_list_page.dart")
New-FileSafe (Join-Path $tpPres "pages/tuition_post_detail_page.dart")
New-FileSafe (Join-Path $tpPres "pages/create_tuition_post_page.dart")
New-FileSafe (Join-Path $tpPres "widgets/tuition_post_card.dart")
New-FileSafe (Join-Path $tpPres "widgets/tuition_post_form.dart")

# ============================
# Feature: Applications
# ============================

$appBase   = Join-Path $featuresDir "applications"
$appData   = Join-Path $appBase "data"
$appDomain = Join-Path $appBase "domain"
$appPres   = Join-Path $appBase "presentation"

New-DirSafe (Join-Path $appData   "datasources")
New-DirSafe (Join-Path $appData   "repositories")
New-DirSafe (Join-Path $appDomain "entities")
New-DirSafe (Join-Path $appDomain "repositories")
New-DirSafe (Join-Path $appDomain "usecases")
New-DirSafe (Join-Path $appPres   "bloc")
New-DirSafe (Join-Path $appPres   "pages")
New-DirSafe (Join-Path $appPres   "widgets")

New-FileSafe (Join-Path $appData "datasources/applications_remote_data_source.dart")
New-FileSafe (Join-Path $appData "repositories/applications_repository_impl.dart")

New-FileSafe (Join-Path $appDomain "entities/tuition_application.dart")
New-FileSafe (Join-Path $appDomain "repositories/applications_repository.dart")
New-FileSafe (Join-Path $appDomain "usecases/apply_to_tuition_post_usecase.dart")
New-FileSafe (Join-Path $appDomain "usecases/get_my_applications_usecase.dart")

New-FileSafe (Join-Path $appPres "bloc/applications_cubit.dart")
New-FileSafe (Join-Path $appPres "pages/my_applications_page.dart")
New-FileSafe (Join-Path $appPres "widgets/application_card.dart")

# ============================
# Feature: Search
# ============================

$searchBase   = Join-Path $featuresDir "search"
$searchData   = Join-Path $searchBase "data"
$searchDomain = Join-Path $searchBase "domain"
$searchPres   = Join-Path $searchBase "presentation"

New-DirSafe (Join-Path $searchData   "datasources")
New-DirSafe (Join-Path $searchData   "repositories")
New-DirSafe (Join-Path $searchDomain "entities")
New-DirSafe (Join-Path $searchDomain "repositories")
New-DirSafe (Join-Path $searchDomain "usecases")
New-DirSafe (Join-Path $searchPres   "bloc")
New-DirSafe (Join-Path $searchPres   "pages")
New-DirSafe (Join-Path $searchPres   "widgets")

New-FileSafe (Join-Path $searchData "datasources/search_remote_data_source.dart")
New-FileSafe (Join-Path $searchData "repositories/search_repository_impl.dart")

New-FileSafe (Join-Path $searchDomain "entities/search_teacher_result.dart")
New-FileSafe (Join-Path $searchDomain "entities/search_student_result.dart")
New-FileSafe (Join-Path $searchDomain "repositories/search_repository.dart")
New-FileSafe (Join-Path $searchDomain "usecases/search_teachers_usecase.dart")
New-FileSafe (Join-Path $searchDomain "usecases/search_students_usecase.dart")

New-FileSafe (Join-Path $searchPres "bloc/search_cubit.dart")
New-FileSafe (Join-Path $searchPres "pages/search_teachers_page.dart")
New-FileSafe (Join-Path $searchPres "pages/search_students_page.dart")
New-FileSafe (Join-Path $searchPres "widgets/search_filters_sheet.dart")
New-FileSafe (Join-Path $searchPres "widgets/search_result_card.dart")

# ============================
# Feature: Matches
# ============================

$matchBase   = Join-Path $featuresDir "matches"
$matchData   = Join-Path $matchBase "data"
$matchDomain = Join-Path $matchBase "domain"
$matchPres   = Join-Path $matchBase "presentation"

New-DirSafe (Join-Path $matchData   "datasources")
New-DirSafe (Join-Path $matchData   "repositories")
New-DirSafe (Join-Path $matchDomain "entities")
New-DirSafe (Join-Path $matchDomain "repositories")
New-DirSafe (Join-Path $matchDomain "usecases")
New-DirSafe (Join-Path $matchPres   "bloc")
New-DirSafe (Join-Path $matchPres   "pages")
New-DirSafe (Join-Path $matchPres   "widgets")

New-FileSafe (Join-Path $matchData "datasources/matches_remote_data_source.dart")
New-FileSafe (Join-Path $matchData "repositories/matches_repository_impl.dart")

New-FileSafe (Join-Path $matchDomain "entities/match_item.dart")
New-FileSafe (Join-Path $matchDomain "repositories/matches_repository.dart")
New-FileSafe (Join-Path $matchDomain "usecases/get_my_matches_usecase.dart")

New-FileSafe (Join-Path $matchPres "bloc/matches_cubit.dart")
New-FileSafe (Join-Path $matchPres "pages/matches_page.dart")
New-FileSafe (Join-Path $matchPres "widgets/match_card.dart")

# ============================
# Feature: Demo Sessions
# ============================

$demoBase   = Join-Path $featuresDir "demo_sessions"
$demoData   = Join-Path $demoBase "data"
$demoDomain = Join-Path $demoBase "domain"
$demoPres   = Join-Path $demoBase "presentation"

New-DirSafe (Join-Path $demoData   "datasources")
New-DirSafe (Join-Path $demoData   "repositories")
New-DirSafe (Join-Path $demoDomain "entities")
New-DirSafe (Join-Path $demoDomain "repositories")
New-DirSafe (Join-Path $demoDomain "usecases")
New-DirSafe (Join-Path $demoPres   "bloc")
New-DirSafe (Join-Path $demoPres   "pages")
New-DirSafe (Join-Path $demoPres   "widgets")

New-FileSafe (Join-Path $demoData "datasources/demo_sessions_remote_data_source.dart")
New-FileSafe (Join-Path $demoData "repositories/demo_sessions_repository_impl.dart")

New-FileSafe (Join-Path $demoDomain "entities/demo_session.dart")
New-FileSafe (Join-Path $demoDomain "repositories/demo_sessions_repository.dart")
New-FileSafe (Join-Path $demoDomain "usecases/request_demo_session_usecase.dart")
New-FileSafe (Join-Path $demoDomain "usecases/get_demo_sessions_usecase.dart")
New-FileSafe (Join-Path $demoDomain "usecases/update_demo_session_status_usecase.dart")

New-FileSafe (Join-Path $demoPres "bloc/demo_sessions_cubit.dart")
New-FileSafe (Join-Path $demoPres "pages/demo_sessions_page.dart")
New-FileSafe (Join-Path $demoPres "pages/demo_session_detail_page.dart")
New-FileSafe (Join-Path $demoPres "widgets/demo_session_card.dart")

# ============================
# Feature: Chat
# ============================

$chatBase   = Join-Path $featuresDir "chat"
$chatData   = Join-Path $chatBase "data"
$chatDomain = Join-Path $chatBase "domain"
$chatPres   = Join-Path $chatBase "presentation"

New-DirSafe (Join-Path $chatData   "datasources")
New-DirSafe (Join-Path $chatData   "repositories")
New-DirSafe (Join-Path $chatDomain "entities")
New-DirSafe (Join-Path $chatDomain "repositories")
New-DirSafe (Join-Path $chatDomain "usecases")
New-DirSafe (Join-Path $chatPres   "bloc")
New-DirSafe (Join-Path $chatPres   "pages")
New-DirSafe (Join-Path $chatPres   "widgets")

New-FileSafe (Join-Path $chatData "datasources/chat_remote_data_source.dart")
New-FileSafe (Join-Path $chatData "datasources/chat_socket_data_source.dart")
New-FileSafe (Join-Path $chatData "repositories/chat_repository_impl.dart")

New-FileSafe (Join-Path $chatDomain "entities/chat_room.dart")
New-FileSafe (Join-Path $chatDomain "entities/chat_message.dart")
New-FileSafe (Join-Path $chatDomain "repositories/chat_repository.dart")
New-FileSafe (Join-Path $chatDomain "usecases/get_my_chat_rooms_usecase.dart")
New-FileSafe (Join-Path $chatDomain "usecases/get_chat_messages_usecase.dart")
New-FileSafe (Join-Path $chatDomain "usecases/send_chat_message_usecase.dart")
New-FileSafe (Join-Path $chatDomain "usecases/mark_chat_read_usecase.dart")

New-FileSafe (Join-Path $chatPres "bloc/chat_rooms_cubit.dart")
New-FileSafe (Join-Path $chatPres "bloc/chat_messages_cubit.dart")
New-FileSafe (Join-Path $chatPres "pages/chat_rooms_page.dart")
New-FileSafe (Join-Path $chatPres "pages/chat_page.dart")
New-FileSafe (Join-Path $chatPres "widgets/chat_message_bubble.dart")
New-FileSafe (Join-Path $chatPres "widgets/chat_input_bar.dart")

# ============================
# Feature: Notifications
# ============================

$notifBase   = Join-Path $featuresDir "notifications"
$notifData   = Join-Path $notifBase "data"
$notifDomain = Join-Path $notifBase "domain"
$notifPres   = Join-Path $notifBase "presentation"

New-DirSafe (Join-Path $notifData   "datasources")
New-DirSafe (Join-Path $notifData   "repositories")
New-DirSafe (Join-Path $notifDomain "entities")
New-DirSafe (Join-Path $notifDomain "repositories")
New-DirSafe (Join-Path $notifDomain "usecases")
New-DirSafe (Join-Path $notifPres   "bloc")
New-DirSafe (Join-Path $notifPres   "pages")
New-DirSafe (Join-Path $notifPres   "widgets")

New-FileSafe (Join-Path $notifData "datasources/notifications_remote_data_source.dart")
New-FileSafe (Join-Path $notifData "repositories/notifications_repository_impl.dart")

New-FileSafe (Join-Path $notifDomain "entities/app_notification.dart")
New-FileSafe (Join-Path $notifDomain "repositories/notifications_repository.dart")
New-FileSafe (Join-Path $notifDomain "usecases/get_my_notifications_usecase.dart")
New-FileSafe (Join-Path $notifDomain "usecases/mark_notification_read_usecase.dart")

New-FileSafe (Join-Path $notifPres "bloc/notifications_cubit.dart")
New-FileSafe (Join-Path $notifPres "pages/notifications_page.dart")
New-FileSafe (Join-Path $notifPres "widgets/notification_tile.dart")

# ============================
# Feature: Reviews
# ============================

$revBase   = Join-Path $featuresDir "reviews"
$revData   = Join-Path $revBase "data"
$revDomain = Join-Path $revBase "domain"
$revPres   = Join-Path $revBase "presentation"

New-DirSafe (Join-Path $revData   "datasources")
New-DirSafe (Join-Path $revData   "repositories")
New-DirSafe (Join-Path $revDomain "entities")
New-DirSafe (Join-Path $revDomain "repositories")
New-DirSafe (Join-Path $revDomain "usecases")
New-DirSafe (Join-Path $revPres   "bloc")
New-DirSafe (Join-Path $revPres   "pages")
New-DirSafe (Join-Path $revPres   "widgets")

New-FileSafe (Join-Path $revData "datasources/reviews_remote_data_source.dart")
New-FileSafe (Join-Path $revData "repositories/reviews_repository_impl.dart")

New-FileSafe (Join-Path $revDomain "entities/teacher_review.dart")
New-FileSafe (Join-Path $revDomain "repositories/reviews_repository.dart")
New-FileSafe (Join-Path $revDomain "usecases/get_teacher_reviews_usecase.dart")
New-FileSafe (Join-Path $revDomain "usecases/add_teacher_review_usecase.dart")

New-FileSafe (Join-Path $revPres "bloc/reviews_cubit.dart")
New-FileSafe (Join-Path $revPres "pages/teacher_reviews_page.dart")
New-FileSafe (Join-Path $revPres "pages/add_review_page.dart")
New-FileSafe (Join-Path $revPres "widgets/review_card.dart")
New-FileSafe (Join-Path $revPres "widgets/review_form.dart")

# ============================
# Feature: Admin
# ============================

$adminBase   = Join-Path $featuresDir "admin"
$adminData   = Join-Path $adminBase "data"
$adminDomain = Join-Path $adminBase "domain"
$adminPres   = Join-Path $adminBase "presentation"

New-DirSafe (Join-Path $adminData   "datasources")
New-DirSafe (Join-Path $adminData   "repositories")
New-DirSafe (Join-Path $adminDomain "entities")
New-DirSafe (Join-Path $adminDomain "repositories")
New-DirSafe (Join-Path $adminDomain "usecases")
New-DirSafe (Join-Path $adminPres   "bloc")
New-DirSafe (Join-Path $adminPres   "pages")
New-DirSafe (Join-Path $adminPres   "widgets")

New-FileSafe (Join-Path $adminData "datasources/admin_remote_data_source.dart")
New-FileSafe (Join-Path $adminData "repositories/admin_repository_impl.dart")

New-FileSafe (Join-Path $adminDomain "entities/admin_stats.dart")
New-FileSafe (Join-Path $adminDomain "entities/admin_user_item.dart")
New-FileSafe (Join-Path $adminDomain "entities/admin_demo_session_item.dart")
New-FileSafe (Join-Path $adminDomain "repositories/admin_repository.dart")
New-FileSafe (Join-Path $adminDomain "usecases/get_admin_stats_usecase.dart")
New-FileSafe (Join-Path $adminDomain "usecases/get_users_for_admin_usecase.dart")
New-FileSafe (Join-Path $adminDomain "usecases/toggle_user_suspension_usecase.dart")
New-FileSafe (Join-Path $adminDomain "usecases/approve_teacher_profile_usecase.dart")
New-FileSafe (Join-Path $adminDomain "usecases/approve_tuition_post_usecase.dart")
New-FileSafe (Join-Path $adminDomain "usecases/approve_application_usecase.dart")
New-FileSafe (Join-Path $adminDomain "usecases/get_demo_sessions_admin_usecase.dart")
New-FileSafe (Join-Path $adminDomain "usecases/update_demo_session_status_admin_usecase.dart")

New-FileSafe (Join-Path $adminPres "bloc/admin_dashboard_cubit.dart")
New-FileSafe (Join-Path $adminPres "pages/admin_dashboard_page.dart")
New-FileSafe (Join-Path $adminPres "pages/admin_users_page.dart")
New-FileSafe (Join-Path $adminPres "pages/admin_demo_sessions_page.dart")
New-FileSafe (Join-Path $adminPres "widgets/admin_stats_header.dart")
New-FileSafe (Join-Path $adminPres "widgets/admin_user_list_item.dart")
New-FileSafe (Join-Path $adminPres "widgets/admin_demo_session_card.dart")

# ============================
# Feature: Settings & Account
# ============================

$settingsBase = Join-Path $featuresDir "settings"
$settingsPres = Join-Path $settingsBase "presentation"

New-DirSafe (Join-Path $settingsPres "pages")
New-DirSafe (Join-Path $settingsPres "widgets")
New-DirSafe (Join-Path $settingsPres "bloc")

New-FileSafe (Join-Path $settingsPres "pages/settings_page.dart")
New-FileSafe (Join-Path $settingsPres "pages/account_settings_page.dart")
New-FileSafe (Join-Path $settingsPres "bloc/settings_cubit.dart")
New-FileSafe (Join-Path $settingsPres "widgets/settings_section.dart")
New-FileSafe (Join-Path $settingsPres "widgets/settings_tile.dart")

# ============================
# Shared / generic UI
# ============================

$sharedDialogs = Join-Path $sharedDir "dialogs"
$sharedSheets  = Join-Path $sharedDir "bottom_sheets"
$sharedForms   = Join-Path $sharedDir "forms"

New-DirSafe $sharedDialogs
New-DirSafe $sharedSheets
New-DirSafe $sharedForms

New-FileSafe (Join-Path $sharedDialogs "confirm_dialog.dart")
New-FileSafe (Join-Path $sharedDialogs "info_dialog.dart")
New-FileSafe (Join-Path $sharedSheets  "app_bottom_sheet.dart")
New-FileSafe (Join-Path $sharedForms   "form_section.dart")

Write-Host ""
Write-Host "✅ Folder structure and empty Dart files created successfully."
Write-Host "   Location: $baseDir"
