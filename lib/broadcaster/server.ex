# The MIT License (MIT)

# Copyright (c) 2022 K. S. Ernest (iFire) Lee

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

defmodule Broadcaster.Server do
  require Logger
  @user_name "user_name"
  @user_color "user_color"
  @join_room 1
  @leave_room 3
  @list_rooms 4
  @content 5 # Server: ask client to send initial room content; Client: notify server content has been sent
  @clear_content 6 # Server: ask client to clear its own content before room content is sent
  @delete_room 7

  def accept(port) do
    opts = [:binary, packet: :raw, active: false, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(port, opts)
    # :khepri.start()
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Task.start_link(fn -> serve(client) end)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    state = {}
    data = recv_data(socket, state)
    {:ok, result, _rest, _state} = read_data(data, state)
    # :khepri.put("/:broadcaster/:server/alice", "alice@example.org")
    # ret = :khepri.get("/:broadcaster/:server/alice"),
    # write_line(data, socket)
    serve(socket)
  end

  def read_string(data, state) do
    <<length::native-integer, rest::binary>> = data
    string = ""
    if is_number(length) and length > 0 do
      <<length::native-integer, ^string::binary-size(length), ^rest::binary>> = data
    end
    {:ok, string, rest, state}
  end

  @spec read_data(any, any) :: {:ok, nil, any, any}
  def read_data(data, state)  when not is_nil(data) do
    <<size::signed-little-64, rest::binary>> = data
    Logger.info "size is #{size}"
    <<command_id::signed-little-32, rest::binary>> = rest
    command_id = command_id - 100
    Logger.info "command_id is #{command_id}"
    <<mtype::signed-little-16, rest::binary>> = rest
    Logger.info "mtype is #{mtype}"
    <<user_data::little-binary-size(size), rest::binary>> = rest
    Logger.info "Line message #{user_data}"
    read_data(rest, state)
    # {:ok, {_json, _rest}} = read_string(rest, state)
    # Logger.info "json is #{json}"
    # {:ok, command_id, user_data, state}
    # term = Jason.decode(json, [])
    # case term do
    # {:ok, json} ->
    #   user_name = Map.get(json, @user_name)
    #   Logger.info "Accepting user name #{user_name}"
    #   user_color = Map.get(json, @user_color)
    #   Logger.info "Accepting user color #{user_color}"
    #   state
    # {:error, _other} -> state
    # end
  end

  def read_data(data, state) do
    {:ok, nil, data, state}
  end

  def recv_data(socket, state) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
    line
  end
end
