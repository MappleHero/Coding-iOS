//
//  ProjectFile.m
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectFile.h"
#import "Coding_FileManager.h"

@interface ProjectFile ()
@property (strong, nonatomic) NSString *project_name, *project_owner_name;
@property (strong, nonatomic, readwrite) NSString *diskFileName;
@end

@implementation ProjectFile

+(ProjectFile *)fileWithFileId:(NSNumber *)fileId andProjectId:(NSNumber *)project_id{
    ProjectFile *file = [[ProjectFile alloc] init];
    file.file_id = fileId;
    file.project_id = project_id;
    return file;
}

- (instancetype)initWithFileId:(NSNumber *)fileId inProject:(NSString *)project_name ofUser:(NSString *)project_owner_name{
    self = [super init];
    if (self) {
        _file_id = fileId;
        _project_id = nil;
        _project_name = project_name;
        _project_owner_name = project_owner_name;
    }
    return self;
}

- (void)setOwner_preview:(NSString *)owner_preview{
    _owner_preview = owner_preview;
    if (!_project_id && owner_preview.length > 0) {
        NSString *project_id;
        project_id = [[[[owner_preview componentsSeparatedByString:@"project/"] lastObject] componentsSeparatedByString:@"/"] firstObject];
        _project_id = @(project_id.integerValue);
    }
}

- (BOOL)isEmpty{
    return !(self.storage_key && self.storage_key.length > 0);
}

- (DownloadState)downloadState{
    DownloadState state = DownloadStateDefault;
    if ([self hasBeenDownload]) {
        state = DownloadStateDownloaded;
    }else{
        Coding_DownloadTask *cDownloadTask = [self cDownloadTask];
        if (cDownloadTask) {
            if (cDownloadTask.task.state == NSURLSessionTaskStateRunning) {
                state = DownloadStateDownloading;
            }else if (cDownloadTask.task.state == NSURLSessionTaskStateSuspended) {
                state = DownloadStatePausing;
            }else{
                [Coding_FileManager cancelCDownloadTaskForKey:self.storage_key];
            }
        }
    }
    return state;
}

- (NSString *)downloadPath{
    NSString *path = [NSString stringWithFormat:@"%@api/project/%@/files/%@/download", [NSObject baseURLStr], _project_id.stringValue, _file_id.stringValue];
    return path;
}

- (NSString *)diskFileName{
    if (!_diskFileName) {
        _diskFileName = [NSString stringWithFormat:@"%@|||%@|||%@|%@", _name, _project_id.stringValue, _storage_type, _storage_key];
    }
    return _diskFileName;
}

- (Coding_DownloadTask *)cDownloadTask{
    return [Coding_FileManager cDownloadTaskForKey:_storage_key];
}
- (NSURL *)hasBeenDownload{
    return [Coding_FileManager diskDownloadUrlForKey:_storage_key];
}

- (NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/project/%@/file/delete", _project_id.stringValue];
}
- (NSDictionary *)toDeleteParams{
    return @{@"fileIds" : @[_file_id.stringValue]};
}
- (NSDictionary *)toMoveToParams{
    return @{@"fileId" : @[_file_id.stringValue]};
}

- (NSString *)toDetailPath{
    NSString *path;
    if (!_project_id) {
        path = [NSString stringWithFormat:@"api/user/%@/project/%@/files/%@/view", _project_owner_name, _project_name, _file_id.stringValue];
    }else{
        path = [NSString stringWithFormat:@"api/project/%@/files/%@/view", _project_id.stringValue, _file_id.stringValue];
    }
    return path;
}

- (NSString *)toActivityListPath{
    return [NSString stringWithFormat:@"api/project/%@/file/%@/activities", _project_id.stringValue, _file_id.stringValue];
}

- (NSString *)toHistoryListPath{
    return [NSString stringWithFormat:@"api/project/%@/files/%@/histories", _project_id.stringValue, _file_id.stringValue];
}

- (NSDictionary *)toShareParams{
    return @{
             @"projectId": _project_id,
             @"resourceId": _file_id,
             @"resourceType": @0,
             @"accessType": @0
             };
}
@end

