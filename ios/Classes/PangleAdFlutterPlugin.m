#import "PangleAdFlutterPlugin.h"
#if __has_include(<pangle_ad_flutter/pangle_ad_flutter-Swift.h>)
#import <pangle_ad_flutter/pangle_ad_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pangle_ad_flutter-Swift.h"
#endif

@implementation PangleAdFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPangleAdFlutterPlugin registerWithRegistrar:registrar];
}
@end
