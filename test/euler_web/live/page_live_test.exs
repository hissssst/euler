defmodule EulerWeb.PageLiveTest do
  use EulerWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "INN Verification"
    assert render(page_live) =~ "INN Verification"
  end
end
