import { h, app } from 'hyperapp';
// import { newApiClient, newDummyApiClient } from './api-client';
import { newApiClient } from './api-client';
import {AppState, AppActions, AppView, AppViewMode, TabItem} from './common';
import { Status, statusActions } from './modes/Status';
import { Scan, scanActions } from './modes/Scan';
import { Saved, savedActions } from './modes/Saved';

const React = { createElement: h };

const init = () => {
  const apiClient = newApiClient();
  // const apiClient = newDummyApiClient();

  const initialState: AppState = {
    view: 'status',

    status: {
      deviceStatus: 'loading',
    },

    scan: {
      networks: 'unloaded',
      status: null,
    },

    saved: {
      networks: 'unloaded',
      status: null,
    },

    tabs: [],
    tabsFetched: false,
  };

const actions: AppActions = {
    setView: (view) => (_, actions) => {
      // `oncreate` doesn't seem to work for the other tabs...

      if (view === 'status') {
        actions.status.refresh();
      }

      if (view === 'scan') {
        actions.scan.refresh();
      }

      if (view === 'saved') {
        actions.saved.refresh();
      }

      return { view };
    },

    status: statusActions(apiClient),
    scan: scanActions(apiClient),
    saved: savedActions(apiClient),
    // fetchTabsAndSet: () => (_: AppState, actions: AppActions): void => {
    //     // Static data simulating fetched tabs
    //     const staticTabs = [
    //         { title: 'Static Tab 1', link: '/static1.html' },
    //         { title: 'Static Tab 2', link: '/static2.html' },
    //     ];
    //
    //     console.log('Setting static tabs');
    //     console.log('tabs: ', staticTabs);
    //     actions.setTabs(staticTabs);
    //     actions.setTabsFetched(true);
    // },
    fetchTabsAndSet: () => async (_: AppState, actions: AppActions): Promise<void> => {
      try {
        const tabs = await apiClient.fetchDynamicTabs();
        console.log('got response back Tabs:', tabs);
        actions.setTabs(tabs);
        console.log('called setTabs()');
      } catch (error) {
        console.error('Failed to fetch dynamic tabs', error);
      } finally {
        actions.setTabsFetched(true); // Indicate that fetching is complete
        console.log('called setTabsFetched');
      }
    },
    setTabs: (tabs: TabItem[]) => (state) => {
      // Only update state if tabs is an array
      if (Array.isArray(tabs)) {
        return { ...state, tabs };
      }
      // Otherwise, return an empty object to indicate no state change
      return state;
    },
    setTabsFetched: (fetched: boolean) => (state) => ({ ...state, tabsFetched: fetched }),
  };

  const App: AppView = ({ view, tabs, tabsFetched }, { setView, fetchTabsAndSet }) => (
    <div className='App' oncreate={() => {setView('status'); fetchTabsAndSet(); }}>

      <h1 className='App__heading'>ESP32 Panel</h1>

      <div className='App__tabs'>
        {
          (['status', 'scan', 'saved'] as AppViewMode[]).map((viewButton) =>
            <button
              className={'App__tab ' + (viewButton === view ? 'App__tab--highlight' : 'App__tab--unhighlight')}
              onclick={() => setView(viewButton)}>{viewButton}
            </button>,
          )
        }

        {
          !tabsFetched
            ? <p>Loading tabs...</p> // Still loading(tabs && tabs.length > 0)
            : tabs.map((tab) => // Loaded, possibly empty
              <button
                className='App__tab App__tab--unhighlight'
                onclick={() => window.location.href = tab.link}>{tab.title}
              </button>)
        }
      </div>

      <div className='App__view'>
        {
          view === 'status' && <Status />
        }

        {
          view === 'scan' && <Scan />
        }

        {
          view === 'saved' && <Saved />
        }
      </div>

    </div>
  );

  app(initialState, actions, App, document.body);
};

window.addEventListener('load', init);
