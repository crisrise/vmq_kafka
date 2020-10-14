-module(vmq_kafka).

-include_lib("vernemq_dev/include/vernemq_dev.hrl").


-behaviour(on_publish_hook).

-export([on_publish/6]).

%%%===================================================================
%%% VerneMQ Plugin Hooks
%%%===================================================================

on_publish(_UserName, {MountPoint, ClientId} = _SubscriberId, _QoS, Topic, Payload, _IsRetain) ->
    %error_logger:info_msg("vmq_kafka -> on_publish: ~p ~p ~p ~p ~p ~p", [UserName, SubscriberId, QoS, Topic, Payload, IsRetain]),
    vmq_kafka_worker:send({MountPoint, ClientId, Topic, Payload}),
    ok.


