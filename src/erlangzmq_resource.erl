%% @copyright 2016 Choven Corp.
%%
%% This file is part of erlangzmq.
%%
%% erlangzmq is free software: you can redistribute it and/or modify
%% it under the terms of the GNU Affero General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% erlangzmq is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU Affero General Public License for more details.
%%
%% You should have received a copy of the GNU Affero General Public License
%% along with erlangzmq.  If not, see <http://www.gnu.org/licenses/>

%% @doc ZeroMQ Resource Router implementation for Erlang
%% @hidden

-module(erlangzmq_resource).
-behaviour(gen_server).

%% api behaviour
-export([start_link/0]).

%% gen_server behaviors
-export([code_change/3, handle_call/3, handle_cast/2, handle_info/2, init/1, terminate/2]).

%% public API implementation
-spec start_link() -> {ok, Pid::pid()} | {error, Reason::term()}.
start_link() ->
    gen_server:start_link(?MODULE, {}, []).


-record(state, {
          resources :: map()
}).

%% gen_server implementation
init(_Args) ->
    process_flag(trap_exit, true),
    State = #state{
               resources=#{}
              },
    {ok, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

handle_call({accept, SocketPid}, _From, State) ->
    case erlangzmq_peer:accept(none, SocketPid, [multi_socket_type]) of
        {ok, Pid} ->
            {reply, {ok, Pid}, State};
        {error, Reason} ->
            {reply, {error, Reason}, State}
    end;

handle_call({bind, tcp, Host, Port}, _From, State) ->
    Reply = erlangzmq_bind:start_link(Host, Port),
    {reply, Reply, State};

handle_call({bind, Protocol, _Host, _Port}, _From, State) ->
    {reply, {error, {unsupported_protocol, Protocol}}, State};

handle_call({route_resource, Resource}, _From, #state{resources=Resources}=State) ->
    case maps:find(Resource, Resources) of
        {ok, NewSocket} ->
            Flags = gen_server:call(NewSocket, get_flags),
            {reply, {change_socket, NewSocket, Flags}, State};
        error ->
            {reply, close, State}
    end.

handle_cast({attach, Resource, SocketPid}, #state{resources=Resources}=State) ->
    NewResources = Resources#{Resource => SocketPid},
    {noreply, State#state{resources=NewResources}};

handle_cast(CastMsg, State) ->
    error_logger:info_report([
                              unhandled_handle_cast,
                              {module, ?MODULE},
                              {msg, CastMsg}
                             ]),
    {noreply, State}.

handle_info({'EXIT', _Pid, {shutdown, invalid_resource}}, State) ->
    {noreply, State};

handle_info(InfoMsg, State) ->
    error_logger:info_report([
                              unhandled_handle_info,
                              {module, ?MODULE},
                              {msg, InfoMsg}
                             ]),
    {noreply, State}.

terminate(_Reason, _State) ->
    %% TODO: close all resources
    ok.
