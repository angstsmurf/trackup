//
//  TrackupExporter.m
//  trackup
//
//  Created by Vincent Tourraine on 14/02/15.
//  Copyright (c) 2015 Studio AMANgA. All rights reserved.
//

#import "TrackupExporter.h"

#import "TrackupDocument.h"


@implementation TrackupExporter

- (NSString *)HTMLStringFromDocument:(TrackupDocument *)document {
    NSMutableArray *versionsStrings = [NSMutableArray array];
    for (TrackupVersion *version in document.versions) {
        if (self.includeRoadmap == NO &&
            [version.title isEqualToString:@"Roadmap"]) {
            continue;
        }

        if (self.includeInProgressVersions == NO &&
            version.isInProgress) {
            continue;
        }

        NSMutableArray *itemsStrings = [NSMutableArray array];
        for (TrackupItem *item in version.items) {
            [itemsStrings addObject:
             [NSString stringWithFormat:
              @"        <li%@>%@</li>\n",
              (item.status == TrackupItemStatusMajor) ? @" class=\"major\"" : @"",
              item.title]];
        }

        NSString *dateString = nil;
        if (version.dateComponents) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *date = [calendar dateFromComponents:version.dateComponents];

            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateStyle = NSDateFormatterLongStyle;

            dateString = [NSString stringWithFormat:
                          @"<time datetime=\"%@-%@-%@\">%@</time>",
                          @(version.dateComponents.year),
                          @(version.dateComponents.month),
                          @(version.dateComponents.day),
                          [dateFormatter stringFromDate:date]];
        }

        [versionsStrings addObject:
         [NSString stringWithFormat:
          @"    <section>\n"
          @"      <h2>%@</h2>\n"
          @"      %@\n"
          @"      <ul>\n"
          @"        %@\n"
          @"      </ul>\n"
          @"    </section>\n",
          version.title,
          dateString ?: @"",
          [itemsStrings componentsJoinedByString:@""]]];
    }

    return [NSString stringWithFormat:
            @"<html>\n"
            @"  <head>\n"
            @"    <title>%@ - Release Notes</title>\n"
            @"    <meta name=\"generator\" content=\"Trackup Editor\">\n"
            @"    <style>\n"
            @"      body {font-family: 'HelveticaNeue'; padding-bottom: 80px;}\n"
            @"      body > * {max-width:600px; margin-left: auto; margin-right: auto;}\n"
            @"      h1 {margin-top: 80px; margin-bottom: 4px;}\n"
            @"      h2 {margin-top: 40px; margin-bottom: 4px;}\n"
            @"      time {color: #888;}\n"
            @"      ul {padding-left: 20px;}\n"
            @"      li.major {font-weight: bold;}\n"
            @"    </style>\n"
            @"  </head>\n"
            @"  <body>\n"
            @"    <h1>%@ Release Notes</h1>\n"
            @"    <div><a href=\"%@\">%@</a></div>\n"
            @"    %@\n"
            @"  </body>\n"
            @"</html>",
            document.title,
            document.title,
            document.URL.absoluteString,
            document.URL.absoluteString,
            [versionsStrings componentsJoinedByString:@""]];
}

@end
