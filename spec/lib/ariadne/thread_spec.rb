# frozen_string_literal: true

require "ariadne/thread"

RSpec.describe Ariadne::Thread do
  subject(:thread) do
    described_class.new(
      include_paths: ["spec/dummy/app"]
    )
  end

  let(:call) do
    thread.call do
      Services::CreateService.call(1, kwarg: 2) { User.build("Jane Doe") }
    end
  end

  describe "#call" do
    it "output traces" do
      expect { call }.to output.to_stdout
    end
  end

  describe "#seams" do
    let(:seams_data) do
      seam_methods = %i[rank depth klass method_name prefix]
      parameter_methods = %i[param arg]
      thread.seams.map do |seam|
        seam_methods.to_h { [_1, seam.public_send(_1)] }.tap do |hash|
          hash[:parameters] =
            seam.parameters.map do |parameter|
              parameter_methods.to_h { [_1, parameter.public_send(_1)] }
            end
        end
      end
    end

    let(:expectations) do
      [
        {
          rank: 0,
          depth: 0,
          klass: Services::CreateService,
          method_name: :call,
          prefix: ".",
          parameters: [
            {
              param: :args,
              arg: [
                1
              ]
            },
            {
              param: :kwargs,
              arg: {
                kwarg: 2
              }
            },
            {
              param: :block,
              arg: kind_of(Proc)
            }
          ]
        },
        {
          rank: 1,
          depth: 1,
          klass: Services::CreateService,
          method_name: :initialize,
          prefix: "#",
          parameters: [
            {
              param: :arg,
              arg: 1
            },
            {
              param: :kwarg,
              arg: 2
            }
          ]
        },
        {
          rank: 2,
          depth: 1,
          klass: Services::CreateService,
          method_name: :call,
          prefix: "#",
          parameters: []
        },
        {
          rank: 3,
          depth: 2,
          klass: Services::CreateService,
          method_name: :method_a,
          prefix: "#",
          parameters: [
            {
              param: :x,
              arg: 42
            },
            {
              param: :y,
              arg: kind_of(Class)
            }
          ]
        },
        {
          rank: 4,
          depth: 2,
          klass: Services::CreateService,
          method_name: :method_b,
          prefix: "#",
          parameters: [
            {
              param: :kwarg,
              arg: 42
            }
          ]
        },
        {
          rank: 5,
          depth: 2,
          klass: Services::CreateService,
          method_name: :method_c,
          prefix: "#",
          parameters: [
            {
              param: :args,
              arg: %w[
                foo
                bar
              ]
            }
          ]
        },
        {
          rank: 6,
          depth: 2,
          klass: Services::CreateService,
          method_name: :method_d,
          prefix: "#",
          parameters: [
            {
              param: :args,
              arg: [
                42
              ]
            },
            {
              param: :kwargs,
              arg: {
                kwarg: 43
              }
            },
            {
              param: :block,
              arg: kind_of(Proc)
            }
          ]
        },
        {
          rank: 7,
          depth: 3,
          klass: Services::CreateService,
          method_name: :method_e,
          prefix: "#",
          parameters: [
            {
              param: :arg,
              arg: 42
            },
            {
              param: :kwarg,
              arg: 43
            }
          ]
        },
        {
          rank: 8,
          depth: 2,
          klass: User,
          method_name: :build,
          prefix: ".",
          parameters: [
            {
              param: :name,
              arg: "Jane Doe"
            }
          ]
        },
        {
          rank: 9,
          depth: 3,
          klass: User,
          method_name: :initialize,
          prefix: "#",
          parameters: [
            {
              param: :name,
              arg: { name: "Jane Doe" }
            }
          ]
        },
        {
          rank: 10,
          depth: 2,
          klass: Services::CreateService,
          method_name: :method_a,
          prefix: "#",
          parameters: [
            {
              param: :x,
              arg: 1
            },
            {
              param: :y,
              arg: 2
            }
          ]
        },
        {
          rank: 11,
          depth: 2,
          klass: Services::CreateService,
          method_name: :validate,
          prefix: "#",
          parameters: []
        },
        {
          rank: 12,
          depth: 2,
          klass: Services::ServiceHelper,
          method_name: :validate,
          prefix: ".",
          parameters: []
        }
      ]
    end

    before do
      # do not output during the tests to avoid vizual pollution
      log = double(Ariadne::Log, call: nil)
      allow(Ariadne::Log).to receive(:new).and_return(log)
      call
    end

    it "returns the seams" do
      expect(seams_data.size).to eq 13
      expectations.each.with_index do |expectation, index|
        expect(seams_data.find { _1[:rank] == index }).to match(expectation)
      end
    end
  end
end
