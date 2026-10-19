# Ruby 3.2+ removed Object#tainted?/#taint/#untaint, but the Liquid gem
# version Jekyll depends on (~> 4.0) still calls tainted? internally.
# Restore them as harmless no-ops so Liquid rendering doesn't crash.
class Object
  def tainted?
    false
  end

  def taint
    self
  end

  def untaint
    self
  end
end
