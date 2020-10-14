-module(vmq_kafka_worker).
-author("candreola").

-export([send/1]).

-behaviour(gen_server).

-export([start_link/0, init/1, terminate/2, code_change/3, handle_call/3, handle_cast/2, handle_info/2]).

-define(SERVER_NAME, ?MODULE).

-include("kafka_proto.hrl").

-record(state, {
  brod_client,
  num_partitions,
  kafka_topic
}).

-type state() :: #state{}.

%%%===================================================================
%%% OTP Part
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER_NAME}, ?MODULE, {}, []).

init(_Args) ->
  process_flag(trap_exit, true),
  {ok, BrodClient} = application:get_env(vmq_kafka, brod_client),
  {ok, NumPartitions} = application:get_env(vmq_kafka, num_partitions),
  {ok, KafkaTopic} = application:get_env(vmq_kafka, kafka_topic),
  State = #state{brod_client = BrodClient, num_partitions = NumPartitions, kafka_topic = KafkaTopic},
  {ok, State}.

handle_cast({Mountpoint, ClientId, Topic, Payload}, State) ->
  BrodClient = list_to_atom(State#state.brod_client),
  NumPartitions = State#state.num_partitions,
  KafkaTopic = list_to_binary(State#state.kafka_topic),
  BinMessage = kafka_proto:encode_msg(#'mqtt'{mountpoint=Mountpoint, client_id=ClientId, topic=Topic, payload=Payload}),
  CurrentPartition = rand:uniform(NumPartitions) - 1,
  ok = brod:produce_sync(BrodClient, KafkaTopic, CurrentPartition, _Key = <<>>, BinMessage),
  {noreply, State}.

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_info(_Info, State) ->
  {noreply, State}.

-spec terminate(_, state()) -> ok.
terminate(_Reason, _State) ->
  ok.

-spec code_change(term(), state(), term()) -> {ok, state()}.
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Public Hooks
%%%===================================================================

send(Message)->
  gen_server:cast(?SERVER_NAME, Message).

