defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> drwa_image
    |> save_image(input)
  end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _rest]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(fn [a, b, c] -> [a, b, c, b, a] end)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
    # |> Enum.map(&mirror_row/1) 
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    fileterd_grid =
      grid
      |> Enum.filter(fn {code, _index} ->
        rem(code, 2) == 0
      end)

    %Identicon.Image{image | grid: fileterd_grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      grid
      |> Enum.map(fn {_code, index} ->
        x1 = rem(index, 5) * 50
        y1 = div(index, 5) * 50
        top_left = {x1, y1}
        bottom_right = {x1 + 50, y1 + 50}
        {top_left, bottom_right}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def drwa_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start_pixel, stop_pixel} ->
      :egd.filledRectangle(image, start_pixel, stop_pixel, fill)
    end)

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def mirror_row([a, b | _rest] = row) do
    row ++ [b, a]
  end
end
