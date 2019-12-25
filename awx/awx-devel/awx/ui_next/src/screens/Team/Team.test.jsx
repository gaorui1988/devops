import React from 'react';
import { createMemoryHistory } from 'history';
import { TeamsAPI } from '@api';
import { mountWithContexts, waitForElement } from '@testUtils/enzymeHelpers';
import Team from './Team';

jest.mock('@api');

const mockMe = {
  is_super_user: true,
  is_system_auditor: false,
};

const mockTeam = {
  id: 1,
  name: 'Test Team',
  summary_fields: {
    organization: {
      id: 1,
      name: 'Default',
    },
  },
};

async function getTeams() {
  return {
    count: 1,
    next: null,
    previous: null,
    data: {
      results: [mockTeam],
    },
  };
}

describe('<Team />', () => {
  test('initially renders succesfully', () => {
    TeamsAPI.readDetail.mockResolvedValue({ data: mockTeam });
    TeamsAPI.read.mockImplementation(getTeams);
    mountWithContexts(<Team setBreadcrumb={() => {}} me={mockMe} />);
  });

  test('should show content error when user attempts to navigate to erroneous route', async () => {
    const history = createMemoryHistory({
      initialEntries: ['/teams/1/foobar'],
    });
    const wrapper = mountWithContexts(
      <Team setBreadcrumb={() => {}} me={mockMe} />,
      {
        context: {
          router: {
            history,
            route: {
              location: history.location,
              match: {
                params: { id: 1 },
                url: '/teams/1/foobar',
                path: '/teams/1/foobar',
              },
            },
          },
        },
      }
    );
    await waitForElement(wrapper, 'ContentError', el => el.length === 1);
  });
});
