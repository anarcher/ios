//
//  ServersDataSource.m
//  IRCCloud
//
//  Created by Sam Steele on 2/24/13.
//  Copyright (c) 2013 IRCCloud, Ltd. All rights reserved.
//

#import "ServersDataSource.h"

@implementation Server
-(NSComparisonResult)compare:(Server *)aServer {
    if(aServer.cid < _cid)
        return NSOrderedAscending;
    else if(aServer.cid > _cid)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}
-(NSString *)description {
    return [NSString stringWithFormat:@"{cid: %i, name: %@, hostname: %@, port: %i}", _cid, _name, _hostname, _port];
}
@end

@implementation ServersDataSource
+(ServersDataSource *)sharedInstance {
    static ServersDataSource *sharedInstance;
	
    @synchronized(self) {
        if(!sharedInstance)
            sharedInstance = [[ServersDataSource alloc] init];
		
        return sharedInstance;
    }
	return nil;
}

-(id)init {
    self = [super init];
    _servers = [[NSMutableArray alloc] init];
    return self;
}

-(void)clear {
    @synchronized(_servers) {
        [_servers removeAllObjects];
    }
}

-(void)addServer:(Server *)server {
    @synchronized(_servers) {
        [_servers addObject:server];
        [_servers sortUsingSelector:@selector(compare:)];
    }
}

-(NSArray *)getServers {
    @synchronized(_servers) {
        return (NSArray *)_servers;
    }
}

-(Server *)getServer:(int)cid {
    @synchronized(_servers) {
        for(Server *server in _servers) {
            if(server.cid == cid)
                return server;
        }
    }
    return nil;
}

-(Server *)getServer:(NSString *)hostname port:(int)port {
    @synchronized(_servers) {
        for(Server *server in _servers) {
            if([server.hostname isEqualToString:hostname] && (port == -1 || server.port == port))
                return server;
        }
        return nil;
    }
}

-(Server *)getServer:(NSString *)hostname SSL:(BOOL)ssl {
    @synchronized(_servers) {
        for(Server *server in _servers) {
            if([server.hostname isEqualToString:hostname] && ((ssl == YES && server.ssl > 0) || (ssl == NO && server.ssl == 0)))
                return server;
        }
        return nil;
    }
}

-(void)removeServer:(int)cid {
    @synchronized(_servers) {
        Server *server = [self getServer:cid];
        if(server)
            [_servers removeObject:server];
    }
}

-(void)removeAllDataForServer:(int)cid {
    @synchronized(_servers) {
        Server *server = [self getServer:cid];
        if(server) {
            [_servers removeObject:server];
            //TODO: Clear the other data sources
        }
    }
}

-(int)count {
    @synchronized(_servers) {
        return _servers.count;
    }
}

-(void)updateLag:(long)lag server:(int)cid {
    @synchronized(_servers) {
        Server *server = [self getServer:cid];
        if(server)
            server.lag = lag;
    }
}

-(void)updateNick:(NSString *)nick server:(int)cid {
    @synchronized(_servers) {
        Server *server = [self getServer:cid];
        if(server)
            server.nick = nick;
    }
}

-(void)updateStatus:(NSString *)status failInfo:(NSDictionary *)failInfo server:(int)cid {
    @synchronized(_servers) {
        Server *server = [self getServer:cid];
        if(server) {
            server.status = status;
            server.fail_info = failInfo;
        }
    }
}

-(void)updateAway:(NSString *)away server:(int)cid {
    @synchronized(_servers) {
        Server *server = [self getServer:cid];
        if(server)
            server.away = away;
    }
}

-(void)updateUsermask:(NSString *)usermask server:(int)cid {
    @synchronized(_servers) {
        Server *server = [self getServer:cid];
        if(server)
            server.usermask = usermask;
    }
}

-(void)updateMode:(NSString *)mode server:(int)cid {
    @synchronized(_servers) {
        Server *server = [self getServer:cid];
        if(server)
            server.mode = mode;
    }
}

-(void)updateIsupport:(NSDictionary *)isupport server:(int)cid {
    @synchronized(_servers) {
        Server *server = [self getServer:cid];
        if(server)
            server.isupport = isupport;
    }
}

-(void)updateIgnores:(NSArray *)ignores server:(int)cid {
    @synchronized(_servers) {
        Server *server = [self getServer:cid];
        if(server)
            server.ignores = ignores;
    }
}
@end