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

-module(erlangzmq_lb_test).

-include_lib("eunit/include/eunit.hrl").

new_test() ->
    ?assertEqual(erlangzmq_lb:new(), []).

put_test() ->
    Q1 = erlangzmq_lb:new(),
    Q2 = erlangzmq_lb:put(Q1, 1),
    ?assertEqual(Q2, [1]),
    Q3 = erlangzmq_lb:put(Q2, 3),
    ?assertEqual(Q3, [3, 1]).

get_test() ->
    Q1 = erlangzmq_lb:put(
          erlangzmq_lb:put(erlangzmq_lb:new(), 1),
          3),
    {Q2, 3} = erlangzmq_lb:get(Q1),
    {Q3, 1} = erlangzmq_lb:get(Q2),
    {Q4, 3} = erlangzmq_lb:get(Q3),
    ?assertEqual(Q4, [1, 3]).

get_empty_test() ->
    ?assertEqual(erlangzmq_lb:get(erlangzmq_lb:new()), none).

delete_test() ->
    Q1 = erlangzmq_lb:put(
          erlangzmq_lb:put(erlangzmq_lb:new(), 1),
          3),
    Q2 = erlangzmq_lb:delete(Q1, 1),
    Q3 = erlangzmq_lb:delete(Q1, 3),

    ?assertEqual(Q2, [3]),
    ?assertEqual(Q3, [1]).
