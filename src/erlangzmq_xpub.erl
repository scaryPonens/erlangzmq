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

%% @doc ZeroMQ XPub Pattern for Erlang
%%
%% This pattern implement XPub especification
%% from: http://rfc.zeromq.org/spec:29/PUBSUB#toc4

-module(erlangzmq_xpub).

-export([valid_peer_type/1, init/1]).

valid_peer_type(Type) ->
    erlangzmq_pub:valid_peer_type(Type).

init(Identity) ->
    erlangzmq_pub:init(Identity, [xpub]).
