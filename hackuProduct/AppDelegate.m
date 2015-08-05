
#import "AppDelegate.h"
#import "BookShelfCollectionViewController.h"
#import "FriendViewController.h"
#import "SettingViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "SearchViewController.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window;
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [Parse setApplicationId:@"n3giGyxTaQClMezovu0s6Zm2ZwtiVBD5TlLYOQKf"
                  clientKey:@"6IGF2OOl2KlPvxzBLvqyqCjV42pR7oABaweroQnN"];
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    // colors: 色をカスタマイズできると良さそう
    UIColor *themeColor = [UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0];
    UIColor *unfocusedColor = UIColor.grayColor;
    UIColor *defaultFontColor = UIColor.whiteColor;

    HomeViewController *homeVC = [HomeViewController new];
    FriendViewController *friendVC = [FriendViewController new];
    BookShelfCollectionViewController *bookShelfCollectionVC = [BookShelfCollectionViewController new];
    SearchViewController *searchVC = [SearchViewController new];
    SettingViewController *settingVC = [SettingViewController new];

    UIFont *tabFont = [UIFont fontWithName:@"HiraKakuProN-W6" size:11.0f];

    NSDictionary *attributesNormal = @{NSFontAttributeName:tabFont, NSForegroundColorAttributeName:unfocusedColor};
    [[UITabBarItem appearance] setTitleTextAttributes:attributesNormal forState:UIControlStateNormal];

    NSDictionary *selectedAttributes = @{NSFontAttributeName:tabFont, NSForegroundColorAttributeName:themeColor};
    [[UITabBarItem appearance] setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];

    [homeVC setTitle:@"ホーム"];
    [friendVC setTitle:@"フレンド"];
    [bookShelfCollectionVC setTitle:@"本棚"];
    [searchVC setTitle:@"検索"];
    [settingVC setTitle:@"設定"];
    homeVC.tabBarItem.image = [UIImage imageNamed:@"IconHome"];
    friendVC.tabBarItem.image = [UIImage imageNamed:@"IconFriend"];
    bookShelfCollectionVC.tabBarItem.image = [UIImage imageNamed:@"IconBookshelf"];
    searchVC.tabBarItem.image = [UIImage imageNamed:@"IconSearch"];
    settingVC.tabBarItem.image = [UIImage imageNamed:@"IconSettings"];

    NSArray *viewControllers = @[
        [[UINavigationController alloc] initWithRootViewController:homeVC],
        [[UINavigationController alloc] initWithRootViewController:friendVC],
        [[UINavigationController alloc] initWithRootViewController:bookShelfCollectionVC],
        [[UINavigationController alloc] initWithRootViewController:searchVC],
        [[UINavigationController alloc] initWithRootViewController:settingVC],
    ];

    [UINavigationBar appearance].tintColor = defaultFontColor;
    [UINavigationBar appearance].barTintColor = themeColor;
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTintColor:themeColor];
    [UINavigationBar appearance].titleTextAttributes = @{
        NSForegroundColorAttributeName: defaultFontColor,
        NSFontAttributeName: [UIFont fontWithName:@"HiraKakuProN-W6" size:20.0f],
    };
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HiraKakuProN-W6" size:14.0f]} forState:UIControlStateNormal];

    self.tabBarController = [UITabBarController new];
    self.tabBarController.delegate = self;
    [self.tabBarController setViewControllers:viewControllers];

    self.window.rootViewController = self.tabBarController;

    [self.window makeKeyAndVisible];

    [LoginViewController showLoginIfNotLoggedIn:self.tabBarController];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (UIViewController*)switchTabBarController:(NSInteger)selectedViewIndex
{
    UITabBarController *controller = (UITabBarController *)tabBarController;
    controller.selectedViewController = [controller.viewControllers objectAtIndex:selectedViewIndex];
    [self tabBarController:controller didSelectViewController:controller.selectedViewController];
    return controller.selectedViewController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // 他のタブに移動した時に最初の画面を表示するようにする
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
    }
}

@end
