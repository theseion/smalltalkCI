baseline
baseline: spec
    <baseline>
    spec
        for: #'common'
        do: [ 
            spec
                package: 'SWTDemo-Core';
                package: 'SWTDemo-Tests' with: [ spec requires: #('default') ].
            spec
                group: 'default' with: #('SWTDemo-Core');
                group: 'Tests' with: #('SWTDemo-Tests');
                group: 'TravisCI' with: #('Tests') ]