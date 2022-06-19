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
    opts = [:inet, :binary, packet: :raw, active: false, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(port, opts)
    :khepri.start()
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Task.start_link(fn -> serve(client) end)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    read_line(socket)
    |> read_json
    # :khepri.put("/:broadcaster/:server/alice", "alice@example.org")
    # ret = :khepri.get("/:broadcaster/:server/alice"),
    # write_line(line, socket)
    serve(socket)
  end

  def read_json(line) do
    term = Jason.decode(line, [])
    case term do
    {:ok, json} ->
      user_name = Map.get(json, @user_name)
      Logger.info "Accepting user name #{user_name}"
      user_color = Map.get(json, @user_color)
      Logger.info "Accepting user color #{user_color}"
    end
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    IO.inspect data
    Logger.info "Line message #{data}"
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
    line
  end
end
