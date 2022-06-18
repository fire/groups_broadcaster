defmodule Broadcaster.Server do
  require Logger

  def accept(port) do
    opts =  [:binary, packet: :line, active: false, reuseaddr: true]
    {:ok, socket} =
      :gen_tcp.listen(port, opts)
    {:ok, socket_send} = :gen_tcp.connect({127, 0, 0, 1}, 13800, opts)

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket, socket_send)
  end

  defp loop_acceptor(socket, socket_send) do
    {:ok, client} = :gen_tcp.accept(socket)
    Task.start_link(fn -> serve(client, socket_send) end)
    loop_acceptor(socket, socket_send)
  end

  defp serve(socket, socket_send) do

    line = read_line(socket)
    write_line(line, socket)
    write_line(line, socket_send)

    serve(socket, socket_send)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
    line
  end
end
