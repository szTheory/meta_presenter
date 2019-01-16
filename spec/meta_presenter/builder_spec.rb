require 'spec_helper'

describe MetaPresenter::Builder do
  let(:controller_class) { ApplicationController }
  let(:controller) { controller_class.send(:new) }
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
    end

    context "controller without a presenter" do
      let(:controller_class) { WithoutPresenterController }

      let(:presenter_file_path) { File.join(object.presenter_base_dir, "without_presenter_presenter.rb") }

      context "but file exists" do
        before do
          expect(File).to be_exists(presenter_file_path)
        end

        it { expect { subject }.to raise_error(MetaPresenter::Builder::FileExistsButPresenterNotDefinedError) }
      end
    end

    context "neither a controller nor a mailer" do
      let(:controller_class) { OpenStruct }

      before do
        expect(controller_class < ActionController::Base).to_not be true
        expect(controller_class < ActionMailer::Base).to_not be true
      end

      it { expect { subject }.to raise_error(MetaPresenter::Builder::InvalidControllerError) }
    end

    context "mailer" do
      let(:controller_class) { ApplicationMailer }

      before do
        expect(controller_class < ActionMailer::Base).to be true
      end

      it { is_expected.to be Mailers::ApplicationPresenter }
    end

    context "subclass of ApplicationController" do
      let(:controller_class) { PagesController }

      before do
        expect(controller_class.ancestors).to include(ApplicationController)
      end

      context "action with a presenter class defined" do
        let(:action_name) { "logs" }
        before { expect(Object).to_not be_const_defined('LogsPresenter') }

        it { is_expected.to be Pages::LogsPresenter }
      end

      context "action without a presenter class defined" do
        let(:action_name) { "fairy" }
        before { expect(Object).to_not be_const_defined('FairyPresenter') }

        context "parent presenter defines the method" do

          it "defers to the parent presenter" do
            expect(subject).to be PagesPresenter
          end
        end

        context "parent presenter doesn't define the method" do

          it "defers to the parent presenter" do
            expect(subject).to be PagesPresenter
          end
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