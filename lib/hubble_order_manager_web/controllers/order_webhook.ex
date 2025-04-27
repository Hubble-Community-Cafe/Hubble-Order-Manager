defmodule HubbleOrderManagerWeb.OrderWebhook do
  use HubbleOrderManagerWeb, :controller

  def home(conn, params) do
    x_signature = get_req_header(conn, "x-signature") |> List.first()

    with true <- not is_nil(x_signature),
    {:ok, public_key} <- fetch_public_key(),
    {:ok, decoded_signature} <- Base.decode64(x_signature),
    true <- verify_signature(public_key, conn.assigns[:raw_body], decoded_signature) do

      # Signature is valid, proceed with order creation
      HubbleOrderManager.Orders.create_order(%{
        order_number: params["order_number"] || "12345"
      })
      |> case do
        {:ok, order} ->
          IO.puts("Order created successfully: #{inspect(order)}")

        {:error, changeset} ->
          IO.puts("Failed to create order: #{inspect(changeset)}")
      end

      send_resp(conn, 201, "Success")
    else
      _ ->
        # Signature is invalid or an error occurred
        send_resp(conn, 400, "Invalid signature")
    end
  end

  defp fetch_public_key do
    current_time = System.system_time(:second)
    webhook_public_key_url = Application.get_env(:hubble_order_manager, :webhook)[:webhook_public_key_url]

    case :ets.lookup(:public_key_cache, :public_key) do
      [{:public_key, public_key, timestamp}] when timestamp > current_time ->
        {:ok, public_key}

      _ ->
        case HTTPoison.get(webhook_public_key_url) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            case :public_key.pem_decode(body) do
              [pem_entry] ->
                public_key = :public_key.pem_entry_decode(pem_entry)
                # Cache the public key for 1 hour
                :ets.insert(:public_key_cache, {:public_key, public_key, current_time + 3600})
                {:ok, public_key}

              _ ->
                {:error, "Invalid PEM format"}
            end

          {:ok, %HTTPoison.Response{status_code: status}} ->
            {:error, "Failed to fetch public key: HTTP #{status}"}

          {:error, reason} ->
            {:error, "Failed to fetch public key: #{inspect(reason)}"}
        end
    end
  end

  defp verify_signature(public_key, json_body, decoded_signature) do
    {:RSAPublicKey, modulus, exponent} = public_key
    :crypto.verify(:rsa, :sha256, json_body, decoded_signature, [exponent, modulus])

  end
end
