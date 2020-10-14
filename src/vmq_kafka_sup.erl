-module(vmq_kafka_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    %error_logger:info_msg("vmq_kafka -> sup start_link"),
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    %error_logger:info_msg("vmq_kafka -> sup init child"),
    SupFlags = #{strategy => one_for_one, intensity => 10000, period => 5},
    ChildSpecs = [
        #{id => kafkaworker, start => {vmq_kafka_worker, start_link, []}}
    ],
    {ok, {SupFlags, ChildSpecs}}.

%%====================================================================
%% Internal functions
%%====================================================================