require 'spec_helper'

describe Hydra::PCDM::AddRelatedObjectToObject do

  let(:subject) { Hydra::PCDM::Object.create }

  describe '#call' do

    context 'with acceptable objects' do
      let(:object1) { Hydra::PCDM::Object.create }
      let(:object2) { Hydra::PCDM::Object.create }
      let(:object3) { Hydra::PCDM::Object.create }
      let(:file1)   { Hydra::PCDM::File.new }

      it 'should add a related object to empty object' do
        Hydra::PCDM::AddRelatedObjectToObject.call( subject, object1 )
        expect( Hydra::PCDM::GetRelatedObjectsFromObject.call( subject ) ).to eq [object1]
      end

      it 'should add a related object to object with related objects' do
        Hydra::PCDM::AddRelatedObjectToObject.call( subject, object1 )
        Hydra::PCDM::AddRelatedObjectToObject.call( subject, object2 )
        related_objects = Hydra::PCDM::GetRelatedObjectsFromObject.call( subject )
        expect( related_objects.include? object1 ).to be true
        expect( related_objects.include? object2 ).to be true
        expect( related_objects.size ).to eq 2
      end

      context 'with files and objects' do
        let(:file1) { subject.files.build }
        let(:file2) { subject.files.build }

        before do
          file1.content = "I'm a file"
          file2.content = "I am too"
          Hydra::PCDM::AddObjectToObject.call( subject, object1 )
          Hydra::PCDM::AddRelatedObjectToObject.call( subject, object2 )
          subject.save!
        end

        it 'should add an object to an object with files and objects' do
          Hydra::PCDM::AddRelatedObjectToObject.call( subject, object3 )
          related_objects = Hydra::PCDM::GetRelatedObjectsFromObject.call( subject )
          expect( related_objects.include? object2 ).to be true
          expect( related_objects.include? object3 ).to be true
          expect( related_objects.size ).to eq 2
        end

        it 'should solrize member ids' do
          expect(subject.to_solr["objects_ssim"]).to include(object1.id)
          expect(subject.to_solr["objects_ssim"]).not_to include(object2.id,object3.id)
          # expect(subject.to_solr["objects_ssim"]).not_to include(file1.id,file2.id)
          # expect(subject.to_solr["files_ssim"]).not_to include(file1.id,file2.id)
          # expect(subject.to_solr["files_ssim"]).to include(object1.id,object2.id)
        end
      end
    end

    context 'with unacceptable objects' do
      let(:collection1) { Hydra::PCDM::Collection.create }
      let(:file1) { Hydra::PCDM::File.new }
      let(:non_PCDM_object) { "I'm not a PCDM object" }
      let(:af_base_object)  { ActiveFedora::Base.create }

      let(:error_message) { 'child_related_object must be a pcdm object' }

      it 'should NOT aggregate Hydra::PCDM::Collection in related objects aggregation' do
        expect{ Hydra::PCDM::AddRelatedObjectToObject.call( subject, collection1 ) }.to raise_error(ArgumentError,error_message)
      end

      it 'should NOT aggregate Hydra::PCDM::Files in related objects aggregation' do
        expect{ Hydra::PCDM::AddRelatedObjectToObject.call( subject, file1 ) }.to raise_error(ArgumentError,error_message)
      end

      it 'should NOT aggregate non-PCDM objects in related objects aggregation' do
        expect{ Hydra::PCDM::AddRelatedObjectToObject.call( subject, non_PCDM_object ) }.to raise_error(ArgumentError,error_message)
      end

      it 'should NOT aggregate AF::Base objects in related objects aggregation' do
        expect{ Hydra::PCDM::AddRelatedObjectToObject.call( subject, af_base_object ) }.to raise_error(ArgumentError,error_message)
      end

    end

    context 'with invalid bahaviors' do
      let(:object1) { Hydra::PCDM::Object.create }
      let(:object2) { Hydra::PCDM::Object.create }

      xit 'should NOT allow related objects to repeat' do
        Hydra::PCDM::AddRelatedObjectToObject.call( subject, object1 )
        Hydra::PCDM::AddRelatedObjectToObject.call( subject, object2 )
        Hydra::PCDM::AddRelatedObjectToObject.call( subject, object1 )
        related_objects = Hydra::PCDM::GetRelatedObjectsFromObject.call( subject )
        expect( related_objects.include? object1 ).to be true
        expect( related_objects.include? object2 ).to be true
        expect( related_objects.size ).to eq 2
      end
    end
  end
end