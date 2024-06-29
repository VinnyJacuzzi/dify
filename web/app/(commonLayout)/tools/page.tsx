'use client'
import type { FC } from 'react'
import { useTranslation } from 'react-i18next'
import React, { useEffect } from 'react'
import dynamic from 'next/dynamic'

const ToolProviderList = dynamic(() => import('@/app/components/tools/provider-list'), { ssr: false })

const Layout: FC = () => {
  const { t } = useTranslation()

  useEffect(() => {
    if (typeof window !== 'undefined')
      document.title = `${t('tools.title')} - Dify`
  }, [t])

  return <ToolProviderList />
}

export default React.memo(Layout)
