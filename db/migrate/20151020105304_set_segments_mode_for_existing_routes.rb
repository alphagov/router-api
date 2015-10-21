class SetSegmentsModeForExistingRoutes < Mongoid::Migration
  def self.up
    Route.where(handler: "redirect", segments_mode: nil).each(&:save)
  end
end
