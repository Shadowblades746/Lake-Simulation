# frozen_string_literal: true

require 'minitest/autorun'

eval File.read('lake.rb')

class TestCoordValid < Minitest::Test
  def test_coordValid_1
    assert_equal false, coordValid([[-3]], -1, 0)
  end

  def test_coordValid_2
    assert_equal true, coordValid([[-3, 0], [1, 0]], 0, 0)
  end
end

class TestFlow < Minitest::Test
  def test_flow_1
    lake = [[0, 0, 0], [0, -10, 0], [0, 0, 0]]
    flow(lake, -1, 0, 5)
    assert_equal [[0, 0, 0], [0, -10, 0], [0, 0, 0]], lake
  end

  def test_flow_2
    lake = [[90, 0], [0, 0]]
    flow(lake, 0, 1, 0)
    assert_equal [[67, 0], [23, 0]], lake
  end
end

class TestWaveOverBlocks < Minitest::Test
  def test_wave_1
    lake = [[0, 0, 0], [10, -6, 10], [0, 0, 0]]
    waveOverBlocks(lake, 0, 1, 1, 0)
    assert_equal [[0, 0, 0], [10, -6, 10], [0, 0, 0]], lake
  end

  def test_wave_2
    lake = [[0, 0, 0], [11, -7, 10], [0, 0, 0]]
    waveOverBlocks(lake, 0, 1, 1, 0)
    assert_equal [[0, 0, 0], [10, -7, 11], [0, 0, 0]], lake
  end
end

class TestGradient < Minitest::Test
  def test_gradient_1
    lake = [[0, 2, 0], [0, -3, 0], [0, 7, 0]]
    assert_equal 5, gradient(lake, 1, 1, 0, 1)
  end

  def test_gradient_2
    lake = [[0, 0, 0], [11, 6, 10], [0, 0, 0]]
    assert_equal 0, gradient(lake, 1, 1, 1, 0)
  end
end

class TestCrush < Minitest::Test
  def test_crush_1
    lake = [[0, 0, 0], [11, -7, 0], [0, 0, 0]]
    crush(lake, 10)
    assert_equal [[0, 0, 0], [11, -7, 0], [0, 0, 0]], lake
  end

  def test_crush_2
    lake = [[0, 0, 0], [11, -7, 0], [0, 0, 0]]
    crush(lake, 0)
    assert_equal [[0, 0, 0], [11, 0, 0], [0, 0, 0]], lake
  end
end
# frozen_string_literal: true
