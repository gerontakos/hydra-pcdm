module Hydra::PCDM
  class AddObjectToObject

    ##
    # Add an object to an object.
    #
    # @param [Hydra::PCDM::Object] :parent_object to which to add object
    # @param [Hydra::PCDM::Object] :child_object being added
    #
    # @return [Hydra::PCDM::Object] the updated pcdm object

    def self.call( parent_object, child_object )
      raise ArgumentError, "parent_object must be a pcdm object" unless Hydra::PCDM.object? parent_object
      raise ArgumentError, "child_object must be a pcdm object" unless Hydra::PCDM.object? child_object
      parent_object << child_object
    end

  end
end