require 'spec_helper'

describe MetaPresenter::Builder do
  let(:controller_class) { ApplicationController }
  let(:controller) { controller_class.new }
  let(:action_name) { 'logs' }
  let(:object) { described_class.new(controller, action_name) }

  def controller_ancestors
    controller.class.ancestors
  end

  describe '#new' do
    subject { object }

    it { expect(subject.controller).to eql(controller) }
    it { expect(subject.action_name).to eql(action_name) }
  end

  describe '#presenter_class' do
    subject { object.presenter_class }

    before do
      expect(controller_ancestors.first).to eql(controller_class)
    end

    context "application controller" do
      let(:controller_class) { ApplicationController }

      it { is_expected.to be ApplicationPresenter }

      # TODO: test action variations
    end

    context "subclass of ApplicationController" do
      let(:controller_class) { PagesController }

      context "action with a presenter class defined" do
        let(:action_name) { "logs" }

        it { is_expected.to be Pages::LogsPresenter }
      end

      context "action without a presenter class defined" do
        # Good luck finding that FairyPresenter, doesn't exist!
        let(:action_name) { "fairy" }

        it "defers to the parent presenter" do
          expect(subject).to be PagesPresenter
        end
      end
    end

    # TODO: test namespaces with nested scenarios
  end
end