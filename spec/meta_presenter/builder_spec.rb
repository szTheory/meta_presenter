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

    # TODO: test mailer scenarios

    context "application controller" do
      let(:controller_class) { ApplicationController }

      it { is_expected.to be ApplicationPresenter }
    end

    context "subclass of ApplicationController" do
      let(:controller_class) { PagesController }
      let(:action_name) { "logs" }

      it { is_expected.to be Pages::LogsPresenter }

      context "action without a presenter class defined" do
        # Good luck finding that FairyPresenter, doesn't exist!
        let(:action_name) { "fairy" }

        it "defers to the parent presenter" do
          expect(subject).to be PagesPresenter
        end

        context "but the file exists" do
          let(:action_name) { "only_file_exists" }

          it do
            expect { subject }.to raise_error(MetaPresenter::Builder::FileExistsButPresenterNotDefinedError)
          end
        end
      end
    end

    context "namespaced" do
      let(:controller_class) { Admin::DashboardController }
      let(:action_name) { "inbox" }

      it { is_expected.to be Admin::Dashboard::InboxPresenter }
    end
  end
end